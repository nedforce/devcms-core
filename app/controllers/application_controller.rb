# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include DevcmsCore::AuthenticatedSystem
  include DevcmsCore::RoleRequirementSystem
  include ::SecureHeaders

  protect_from_forgery
  skip_before_action [:verify_authenticity_token, :check_authorization], only: [:handle_500, :handle_404]

  # Catch all exceptions (except 404 errors, which are handled below) to render
  # a custom 500 page. Also makes sure a notification mail is sent.
  # 404 exceptions are handled below.
  rescue_from Exception, :with => :handle_500 if Rails.env.production?

  # Catches all 404 errors to render a 404 page.
  # Note that this rescue_from statement has precedence over the one above.
  # ActionNotFound and RecordNotFound exceptions are given a special treatment, so you don't have to worry about
  # catching them in the +find_[resource]+ methods throughout all controllers.
  rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, :with => :handle_404 unless Rails.env.development?

  before_action :redirect_to_full_domain
  before_action :check_password_renewal, if: :logged_in?

  # Try retrieve the +Node+ object for the current request.
  # This needs to be done before any authorization attempts, a +Node+ might be needed.
  before_action :find_node
  before_action :find_context_node

  # Set view paths
  before_action :set_view_paths
  before_action :set_high_contrast_mode

  # Performs the actual authorization procedure
  before_action :check_authorization

  # Set the private menu items for the side box.
  before_action :set_private_menu

  # Find the children for the current node
  before_action :find_accessible_children_for_menus

  # Set the search options for the search field.
  before_action :set_search_scopes

  before_action :set_page_title

  # Limit the session time
  before_action :extend_and_limit_session_time

  # Set the rss feed url if needed
  before_action :set_rss_feed_url, only: :show

  # Increment the number of hits for the accessed node, if a node was accessed
  after_action :increment_hits, only: :show

  # Set the layout
  layout :set_layout

  # Include all helpers, all the time.
  helper VideoHelper, SitemapsHelper, SearchHelper, PollQuestionsHelper, OwmsMetadataHelper, HtmlEditorHelper, ContactBoxesHelper, CalendarsHelper, AttachmentsHelper, ApplicationHelper, LayoutHelper, IconHelper

  helper_method :layout_configuration, :secure_url, :current_site, :current_user_has_any_role?, :current_user_is_admin?, :current_user_is_editor?, :current_user_is_final_editor?

  # Limits the session time to a certain amount
  def extend_and_limit_session_time
    if Settler[:user_session_time_limit_enabled]
      request.session_options[:expire_after] = current_user && current_user.is_privileged? ? Settler[:user_session_privileged_timeout].minutes : Settler[:user_session_timeout].minutes
    end
  end

  # GET /synonyms.txt
  def synonyms
    synonyms = {}
    Synonym.all.each do |syn|
      synonyms[syn.original] ||= [syn.original]
      synonyms[syn.original] << syn.name
    end
    synonyms = synonyms.map { |key, set| set.uniq.join(', ') }
    send_data synonyms.join("\n"), :filename => 'synonyms.txt', :type => 'text/plain', :disposition => 'attachment'
  end

  # Renders a custom 404 page.
  def handle_404(exception = env["action_dispatch.exception"])
    @page_title = t('errors.page_not_found')
    respond_to do |f|
      f.html do
        if request.xhr?
          render :json => { :error => I18n.t('application.page_not_found') }.to_json, :status => 404
        else
          set_view_paths
          if (error_404_url_alias = Settler[:error_page_404]).present? && @node = Node.find_by_url_alias(error_404_url_alias)
            @page = @node.content
            render :template => 'pages/show', :status => :not_found
          else
            render :template => 'errors/404', :status => :not_found
          end
        end
      end
      f.any(:xml, :js, :atom, :rss) { head 404 }
      f.json { render :json => { :error => I18n.t('application.page_not_found') }.to_json, :status => 404 }
      f.all  { render :nothing => true, :status => :not_found }
    end
  end

  # Renders a custom 500 page. Also makes sure a notification mail is sent.
  def handle_500(exception = env["action_dispatch.exception"])
    return head 406 if exception.class == ActionController::UnknownFormat
    # Some one requested '/500' directly?
    if exception.blank?
      if (error_500_url_alias = Settler[:error_page_500]).present? && @node = Node.find_by_url_alias(error_500_url_alias)
        @page = @node.content
        render :template => 'pages/show', :status => :internal_server_error
      else
        render :template => 'errors/500', :status => :internal_server_error
      end
      return
    end

    send_exception_notification(exception)
    @page_title = t('errors.internal_server_error')

    respond_to do |f|
      f.html do
        if request.xhr?
          render :nothing, :status => :internal_server_error
        else
          set_view_paths
          if (error_500_url_alias = Settler[:error_page_500]).present? && @node = Node.find_by_url_alias(error_500_url_alias)
            @page = @node.content
            render :template => 'pages/show', :status => :internal_server_error
          else
            render :template => 'errors/500', :status => :internal_server_error
          end
        end
      end
      f.all               { render :nothing => true,       :status => :internal_server_error }
    end
  end

  def fullpath
    request.env['ORIGINAL_FULLPATH'] || request.fullpath
  end

protected

  # Used to scope the content (menu's etc) to the current site node
  def current_site
    @current_site ||= Node.with_content_type('Site').find_by_id(params[:site_id]) || Site.find_by_domain(request.host).try(:node) || raise(ActionController::RoutingError, 'No root site found!')
  end

  # Used to find the operated node. Should be used for content nodes only
  def find_node
    return unless params[:id].present? && controller_model.respond_to?(:is_content_node?) && controller_model.is_content_node?
    @node = current_site.self_and_descendants.accessible.include_content.where([ 'content_type = ? AND content_id = ?', controller_model.base_class.name, params[:id].to_i ]).first!

    # Redirect when the appropriate url alias for the node is not used
    if !DevcmsCore.config.allow_content_node_routes && request.get? && request.fullpath == request.env['ORIGINAL_FULLPATH']
      redirect_to aliased_or_delegated_url(@node, params.except(:action, :controller, :id)), status: :moved_permanently
    end
  end

  # Used to find the context node (for authorization purposes)
  def find_context_node
    if @node.present?
      if @node.content_type == 'Section'
        @context_node = @node
      else
        @context_node = @node.self_and_ancestors.sections.include_content.last
      end
    else
      if controller_model
        parent_resource_type = controller_model.parent_type rescue nil

        # Nested controller access
        if parent_resource_type
          name = parent_resource_type.name
          node = current_site.self_and_descendants.accessible.with_content_type(name).include_content.where(content_id: params["#{name.underscore}_id"].to_i).first
          @context_node = node.self_and_ancestors.sections.last if node
        else
          @context_node = current_site
        end
      else
        @context_node = current_site
      end
    end

    raise(ActionController::RoutingError, 'No context node found!') unless @context_node
  end

  # Performs authorization
  def check_authorization
    raise ActiveRecord::RecordNotFound.new('Access denied') unless @context_node.accessible_for_user?(current_user)
  end

  # Increases the number of hits for the currently accessed node, if a node is accessed.
  def increment_hits
    @node.increment_hits! if @node
  end

  def set_rss_feed_url
    unless @node.nil? || @node.content_class == Feed
      if @node.content_type_configuration[:has_own_feed]
        @rss_feed_url = content_node_path(@node, :format => 'rss')
      elsif @node.has_changed_feed || @node.content_class == Section
        @rss_feed_url = content_node_path(@node, :format => 'rss', :action => :changes)
      end
    end
  end

  # Return layout to render
  # Return the default print template if param 'layout' equals 'print'.
  def set_layout
    if %w( print plain ).include? params[:layout]
      params[:layout]
    else
      'default'
    end
  end

  def set_high_contrast_mode
    if params['contrast'].present?
      cookies['high_contrast_mode'] = params.delete('contrast') == 'high'
    end
    @high_contrast_mode = cookies['high_contrast_mode'].to_s == 'true'
  end

  def set_meta_description
    @meta_description = @node.content.try(:meta_description) rescue nil ||
                        @node.content.try(:preamble).try(:truncate, 160, :separator => ' ') rescue nil ||
                        @node.content.try(:description).try(:truncate, 160, :separator => ' ') rescue nil
  end

  # setup internal layout configuration
  # Default to current site, with default variant
  def set_view_paths
    node = @node

    unless node
      node                = current_site
      node.layout_variant = 'default'
    end

    @layout_configuration = node.own_or_inherited_layout_configuration
    @layout               = node.own_or_inherited_layout
    @layout_variant       = node.own_or_inherited_layout_variant
    parent                = @layout.parent

    prepend_view_path("#{parent.path}/views") if parent.present?
    prepend_view_path("#{@layout.path}/views")

    if @layout_variant && @layout_variant[:id] != 'default'
      prepend_view_path("#{parent.path}/#{@layout_variant[:id]}/views") if parent.present?
      prepend_view_path("#{@layout.path}/#{@layout_variant[:id]}/views")
    end
  end

  def layout_configuration
    @layout_configuration
  end

  # Set default GET parameter for layout to plain if current layout is plain.
  # This ensures that all outgoing internal links from a 'plain' page also
  # go to 'plain' pages.
  def default_url_options(options = {})
    (params && params[:layout] == 'plain') ? { :layout => 'plain' } : {}
  end

  # Returns true if we are generating an admin section, false otherwise.
  def admin_section?
    params[:controller].starts_with?('admin')
  end

  # Find the Attachment and Image children belonging to the current Node instance.
  def find_images_and_attachments
    @image_content_nodes = []
    @attachment_nodes = []

    @node.children.accessible.with_content_type(%w(Image Attachment ContentCopy)).include_content.each do |node|
      node = node.content.copied_node if node.content_type == 'ContentCopy'
      if node.content_type == 'Image' && !node.content.is_for_header? && node.content.show_in_listing
        @image_content_nodes << node.content
      elsif node.content_type == 'Attachment'
        @attachment_nodes << node
      end
    end
  end

  ## SSL related functionality ##
  def self.ssl_required *actions
    options = { if: :ssl_required? }
    options[:only] = actions if actions.any?
    force_ssl options
  end

  def ssl_required?
    DevcmsCore.config.ssl_enabled
  end

  # Returns the secure variant of the route generated by the given +route_helper_method+.
  # The given +args+ paremeter is passed on.
  def secure_url(route_helper_method, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.update(protocol: 'https') if DevcmsCore.config.ssl_enabled
    self.send(route_helper_method, *(args << options))
  end

  # Renders the general deletion confirmation form, and cancels the chain.
  def confirm_destroy
    render :action => 'confirm_destroy'
  end

  def send_exception_notification(exception)
    notify_airbrake(exception)
  end

  def set_private_menu
    if logged_in?
      @private_menu_items = find_accessible_private_items_for(current_user)
      @private_menu_items.unshift(['Profielpagina', profile_path])
    else
      @private_menu_items = []
    end
  end

  def find_accessible_private_items_for(user)
    role_assignments = user.role_assignments.to_a
    Node.accessible.is_private.sections.order(:position).select do |node|
      role_assignments.any? { |ra| node.self_and_ancestor_ids.include?(ra.node_id) }
    end
  end

  def set_page_title
    @page_title ||= @node ? @node.content_title : nil
  end

  # Returns true if the current user has any role on a given node, false otherwise.
  def current_user_has_any_role?(node)
    current_user.present? && current_user.has_any_role?(node)
  end

  # Returns true if the current user has a particular role on a given node, false otherwise.
  def current_user_has_role?(role, node = nil)
    if node
      @current_user.has_role_on?(role, node.new_record? ? node.parent : node)
    else
      @current_user.has_role?(role)
    end
  end

  # Returns true if the current user has admin rights on a given node, false otherwise.
  def current_user_is_admin?(node)
    current_user_has_role?('admin', node)
  end

  # Returns true if the current user has final editor rights on a given node, false otherwise.
  def current_user_is_final_editor?(node)
    current_user_has_role?('final_editor', node)
  end

  # Returns true if the current user has editor rights on a given node, false otherwise.
  def current_user_is_editor?(node)
    current_user_has_role?('editor', node)
  end

  # Parse the publication start date corresponding to the passed in +publication_start_date_day+ and +publication_start_date_time+ parameters.
  def parse_publication_start_date
    parse_date(:publication_start_date)
  end

  # Parse the publication end date corresponding to the passed in +publication_end_date_day+ and +publication_end_date_time+ parameters.
  def parse_publication_end_date
    parse_date(:publication_end_date)
  end

  def parse_date(field)
    model = controller_name.classify.tableize.singularize.to_sym

    if params[model]
      date = params[model].delete("#{field}_day")
      time = params[model].delete("#{field}_time")
      params[model][field] = "#{date} #{time}" if date
    end
  end

  SEARCH_SCOPE_SEPARATOR = [ '_______________________________', 'separator' ]

  def set_search_scopes
    @search_scopes = []

    set_default_search_scopes
    set_extra_search_scopes
  end

  def set_default_search_scopes
    @search_scopes << [ t('application.whole_site'), '' ]

    if !current_site.root?
      @search_scopes << [ t('application.current_site'), current_site.id ]
    end

    if @node
      @search_scopes << [ t('application.current_section'), "node_#{@node.id}" ] unless @node == current_site
    elsif params[:search_scope] =~ /node_(\d+)/
      node = Node.find($1)
      @search_scopes << [ t('application.current_section'), "node_#{node.id}" ] unless node == current_site
    end
  end

  def set_extra_search_scopes
    @search_scopes << SEARCH_SCOPE_SEPARATOR

    @search_scopes += @accessible_children_for_menu.map { |c| [ c.title, "node_#{c.id}" ] }
  end

  def find_accessible_children_for_menus
    @accessible_children_for_menu = current_site.children.accessible.is_public.shown_in_menu.reorder(position: :asc)
  end

  def redirect_to_full_domain
    redirect_to "#{request.protocol}#{current_site.content.domain}:#{request.port}#{fullpath}" unless Rails.application.config.consider_all_requests_local || request.host == current_site.content.domain rescue false
  end

  def controller_model
    @controller_model ||= controller_name.classify.split('::').last.constantize rescue nil
  end

  def handle_unverified_request
    # raise ActionController::InvalidAuthenticityToken
    head :unprocessable_entity
  end

  def check_password_renewal
    redirect_to edit_password_renewal_url if current_user.should_renew_password?
  end

private

  def determine_redirect_url(request, ssl)
    protocol = ssl ? 'https' : 'http'
    "#{protocol}://#{determine_host_and_port(request, ssl)}#{fullpath}"
  end
end
