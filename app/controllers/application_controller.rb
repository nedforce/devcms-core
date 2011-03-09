# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptionNotifiable
  include RoleRequirementSystem
  include SslRequirement
  
  
  self.mod_porter_secret = "h6UGA7Hn9N4D8Jsu2SbX"

  # Attempt to login the user from a cookie, if it's set.
  before_filter :login_from_cookie

  before_filter :login_as_admin_on_local_request_to_changes, :only => :all_changes

  # Try retrieve the +Node+ object for the current request.
  # This needs to be done before any authorisation attempts, a +Node+ might be needed.
  before_filter :find_node, :except => [:index, :new, :synonyms, :create]
  
  before_filter :set_page_title

  # Set the private menu items for the side box.
  before_filter :set_private_menu
  
  # Set the search options for the search field.
  before_filter :set_search_scopes


  # Renders confirm_destroy.html.erb if destroy is requested using GET.
  # Hyperlinks with <tt>:method => :delete</tt> will perform a GET request if
  # the browser is not JS enabled.
  #
  # NOTE: Make sure confirm_destroy.html.erb exists for all controllers where you need to
  # make DELETE requests using normal hyperlinks. It will usually display a form
  # asking for confirmation of deletion, and post to the resource path using DELETE.
  # Also remember to add <tt>:member => {:destroy => :any}</tt> to the resource mapping
  # in routes.rb.
  verify :method => [ :get, :delete ], :only => :destroy
  before_filter :confirm_destroy, :only => :destroy

  # Include all helpers, all the time.
  helper VideoHelper, SitemapsHelper, SearchHelper, PollQuestionsHelper, OwmsMetadataHelper, HtmlEditorHelper, ContactBoxesHelper, CalendarsHelper, AttachmentsHelper, ApplicationHelper, TextHelper, LayoutHelper

  helper_method :secure_url, :current_site

  # Ensures the values for the +password+ and +password_confirmation+
  # attributes of users are not logged, for security reasons.
  filter_parameter_logging :password

  # Set the rss feed url if needed
  before_filter :set_rss_feed_url, :only => :show

  # Increment the number of hits for the accessed node, if a node was accessed
  after_filter :increment_hits, :only => :show

  protect_from_forgery

  # Set the layout based on its position in the tree.
  layout :set_layout

  # Catch all exceptions (except 404 errors, which are handled below) to render
  # a custom 500 page. Also makes sure a notification mail is sent.
  # 404 exceptions are handled below.
  rescue_from(Exception, :with => :handle_500) unless Rails.env.development?

  # Catches all 404 errors to render a 404 page.
  # Note that this rescue_from statement has precedence over the one above.
  # UnknownAction and RecordNotFound exceptions are given a special treatment, so you don't have to worry about
  # catching them in the +find_[resource]+ methods throughout all controllers.
  rescue_from(ActionController::RoutingError, ActionController::UnknownController,
                ActionController::UnknownAction, ActiveRecord::RecordNotFound,
                :with => :handle_404) unless Rails.env.development?

  # Called when we need to include hidden nodes on local requests
  # Before filter sets current user to admin on local requests to this method
  def all_changes
    changes
  end

  def changes
    if !@node.nil? && @node.content_class != Feed && params[:format] == 'atom'
      if @node.has_changed_feed
        @nodes = @node.last_changes(:self)
      elsif @node.content_class <= Section
        options       = { :limit => 50 }
        options[:for] = current_user if logged_in?
        @nodes = @node.last_changes(:all, options)[0..24]
      else
        raise ActionController::UnknownAction
      end
      respond_to do |format|
        format.atom { render :template => '/shared/changes', :layout => false }
      end
    else
      raise ActionController::UnknownAction
    end
  end
  
  # GET /synonyms.txt
  def synonyms
    synonyms = {}
    Synonym.all.each do |syn|
      synonyms[syn.original] ||= [syn.original]
      synonyms[syn.original] << syn.name
    end
    synonyms = synonyms.collect { |key, set| set.uniq.join(", ") }
    send_data synonyms.join("\n"), :filename => 'synonyms.txt', :type => 'text/plain', :disposition => 'attachment'
  end
protected

  # Used to scope the content (menu's etc) to the current site node
  def current_site
    return @current_site if @current_site

    @current_site = if params[:site_node_id].present?
      Node.find(params[:site_node_id])
    else
      parts = request.host.split(".")
      parts.shift if parts.first == "www"
      Site.find_by_domain(parts.join('.')).node || Node.root
    end
    raise(ActionController::RoutingError, "No root site found!") unless @current_site

    @current_site
  end

  # Increases the number of hits for the currently accessed node, if a node is accessed.
  def increment_hits
    @node.increment_hits! if @node
  end

  def set_rss_feed_url
    unless @node.nil? || @node.content_class == Feed
      if @node.content_type_configuration[:has_own_feed]
        @rss_feed_url = content_node_path(@node, :format => 'atom')
      elsif @node.has_changed_feed || @node.content_class == Section
        @rss_feed_url = content_node_path(@node, :format => 'atom', :action => :changes)
      end
    end
  end

  # Return layout to render and setup internal layout configuration
  # Default to current site, with default variant
  # Return the default print template if param 'layout' equals 'print'.
  def set_layout
    if params[:layout] == "print"
      return "print"
    elsif params[:layout] == "plain"
      return "plain"
    else
      node = @node
      unless node
        node                = current_site
        node.layout_variant = 'default'
      end        
      @layout_configuration = node.own_or_inherited_layout_configuration
      layout                = node.own_or_inherited_layout
      variant               = node.own_or_inherited_layout_variant
      prepend_view_path("app/layouts/#{layout.parent.id}/views") if layout.parent.present?
      prepend_view_path("app/layouts/#{layout.id}/views")
      if variant
        prepend_view_path("app/layouts/#{layout.parent.id}/#{variant[:id]}/views") if layout.parent.present?
        prepend_view_path("app/layouts/#{layout.id}/#{variant[:id]}/views")
      end  
      return 'default'
    end
  end

  # Set default GET parameter for layout to plain if current layout is plain.
  # This ensures that all outgoing internal links from a 'plain' page also
  # go to 'plain' pages.
  def default_url_options(options = {})
    (params && params[:layout] == 'plain') ? { :layout => 'plain' } : {}
  end

  def find_node
    begin
      if params[:node_id] # set by the routing extension
        @node = admin_section? ? Node.find(params[:node_id]) : @node = current_site.self_and_descendants.find_accessible(params[:node_id], :for => current_user)
      else
        # Try to find out based on the controller name.
        model = controller_name.sub(/_controller\z/, '').classify.constantize.base_class rescue nil
        if model && params.has_key?(:id)
          if model.respond_to?(:is_content_node?) && model.is_content_node?
            @node = case
              when admin_section?
                Node.first(:conditions => { :content_id => params[:id], :content_type => model.name })
              else
                current_site.self_and_descendants.find_accessible(:first, :conditions => { :content_id => params[:id], :content_type => model.name }, :for => current_user)
              end
          elsif model.name == Node.name
            @node = admin_section? ? Node.find(params[:id]) : current_site.self_and_descendants.find_accessible(params[:id], :for => current_user)
          end
        end
      end
      raise ActiveRecord::RecordNotFound unless @node
    rescue ActiveRecord::StatementInvalid
      # Malformed id, throw +ActiveRecord::RecordNotFound+ to trigger a 404.
      raise ActiveRecord::RecordNotFound
    end
  end

  # Returns true if we are generating an admin section, false otherwise.
  def admin_section?
    controller_path =~ /\Aadmin\//
  end

  # Finds the Node object corresponding to the passed in +parent_node_id+ parameter.
  # This method is only used for node creation.
  def find_parent_node
    @parent_node = Node.find(params[:parent_node_id])
  end

  # Find the Attachment and Image children belonging to the current Node instance.
  def find_images_and_attachments
    # Make a best-effort attempt to discover the node if it hasn't been set yet.
    @node ||= find_node
    @image_content_nodes, @attachment_content_nodes = [], []
    if @node
      options  = { :conditions => { :content_type => %w( Image Attachment ContentCopy ) }, :for => current_user }
      children = @node.accessible_content_children(options)
      children.each do |child|
        child = child.copied_node.content if child.is_a?(ContentCopy)
        
        if child.class == Image
          @image_content_nodes << child unless child.is_for_header?
        elsif child.class == Attachment
          @attachment_content_nodes << child
        end
      end
    end
  end

  ## SSL related functionality ##

  # Returns true if SSL encryption is required, else false.
  def ssl_required?
    return false if disable_ssl?
    super
  end

  # Returns the secure variant of the route generated by the given +route_helper_method+.
  # The given +args+ paremeter is passed on.
  def secure_url(route_helper_method, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.update(:protocol => 'https') unless disable_ssl?
    self.send(route_helper_method, *(args << options))
  end

  # Returns true if SSL should be disabled, else false.
  def disable_ssl?
    # We don't need/want SSL encryption in a development environment, or when testing.
    !Settler[:ssl_enabled] || consider_all_requests_local || local_request?
  end

  # Overrides +verify_authenticity_token+ from +RequestForgeryProtection+ to prevent
  # exceptions from being thrown. Instead, a warning message is shown.
  def verify_authenticity_token
    verified_request? || flash.now[:error] = I18n.t('application.invalid_auth_token')
  end

  # Renders the general deletion confirmation form, and cancels the chain.
  def confirm_destroy
    render :action => 'confirm_destroy' if request.get?
  end

  # Renders a custom 404 page.
  def handle_404
    respond_to do |f|
      f.html do
        if request.xhr?
          render :json => { :error => I18n.t('application.page_not_found') }.to_json, :status => 404
        else
          set_search_scopes
          if (error_404_url_alias = Settler[:error_page_404]).present? && @node = Node.find_by_url_alias(error_404_url_alias)
            @page = @node.approved_content
            render :template => 'pages/show', :status => :not_found
          else
            @page_title = "----#{I18n.t('application.page_not_found')}---"
            render :template => "errors/404", :status => :not_found
          end
        end
      end
      f.xml  { head 404 }
      f.json { render :json => { :error => I18n.t('application.page_not_found')}.to_json, :status => 404 }
      f.js   { head 404 }
      f.atom { head 404 }
      f.all  { render :nothing => true, :status => :not_found }
    end
  end

  # Renders a custom 500 page. Also makes sure a notification mail is sent.
  def handle_500(exception)
    send_exception_notification(exception) unless Rails.env.development?
    error = {:error => "#{exception} (#{exception.class})", :backtrace => exception.backtrace.join('\n')}

    respond_to do |f|
      f.html do
        # Re-raise exception to provide developer with stack trace for debugging purposes.
        if Rails.env.development?
          raise exception
        else # in production *and* test (test should simulate production so we can test production behaviour)
          set_search_scopes
          if (error_500_url_alias = Settler[:error_page_500]).present? && @node = Node.find_by_url_alias(error_500_url_alias)
            @page = @node.approved_content
            render :template => 'pages/show', :status => :internal_server_error
          else
            render :template => "errors/500", :status => :internal_server_error
          end
        end
      end
      f.xml  { render :xml  => error.to_xml,  :status => :internal_server_error }
      f.json { render :json => error.to_json, :status => :internal_server_error }
      f.js   { render :json => error.to_json, :status => :internal_server_error }
      f.atom { render :xml  => error.to_xml,  :status => :internal_server_error, :layout => false }
      f.all  { render :nothing => true,       :status => :internal_server_error }
    end
  end

  # Delivers the exception notification email.
  def send_exception_notification(exception)
    deliverer = self.class.exception_data

    data = case deliverer
      when nil    then {}
      when Symbol then send(deliverer)
      when Proc   then deliverer.call(self)
    end

    ExceptionNotifier.deliver_exception_notification(exception, self, request, data)
  end

  def set_private_menu
    @private_menu_items = []
    if logged_in?
      @private_menu_items += [["Profielpagina", profile_path]]
      @private_menu_items += Node.find_accessible(:all, :for => current_user, :conditions => {"nodes.hidden" => true}, :order => :position)
    end
  end

  def set_page_title
    # rather safe than sorry -> rescue nil in case we don't have a node
    @page_title ||= @node.approved_content.content_title rescue nil
  end

  # Returns true if the current user has a particular role on a given node, false otherwise.
  def current_user_has_role?(role, node)
    if node && node.id # does this node exist in the database?
      @current_user.has_role_on?(role, node)
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

  # Login as an admin user if the request is local.
  def login_as_admin_on_local_request_to_changes
    @current_user = RoleAssignment.first(:conditions => { :name => 'admin' }, :include => :user).user if local_request?
  end

  # Login as the Luminis user if the request is done by the crawler.
  def login_as_luminis_user_if_required
    @current_user = User.find_by_login('luminis') if !logged_in? && (request.remote_ip == LUMINIS_CRAWLER_IP)
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
    model = controller_name.classify.constantize.table_name.singularize.to_sym
    if params[model]
      date = params[model].delete("#{field}_day")
      time = params[model].delete("#{field}_time")
      params[model][field] = "#{date} #{time.to_s}" if date
    end
  end

  SEARCH_SCOPE_SEPARATOR = [ '_______________________________', 'separator' ]

  def set_search_scopes
    @search_scopes = []

    set_default_search_scopes
    set_extra_search_scopes
  end

  def set_default_search_scopes
    @search_scopes << [ t('application.site'), "node_#{current_site.id}" ]

    if @node
      @search_scopes << [ t('application.current_section'), "node_#{@node.id}" ] unless @node == current_site
    elsif params[:search_scope] =~ /node_(\d+)/
      node = Node.find($1)
      @search_scopes << [ t('application.current_section'), "node_#{node.id}" ] unless node == current_site
    end
  end

  def set_extra_search_scopes
    @search_scopes << SEARCH_SCOPE_SEPARATOR

    @search_scopes += current_site.accessible_children(:for_menu => true).map { |n| [ n.approved_content.title, "node_#{n.id}" ]}
  end
end
