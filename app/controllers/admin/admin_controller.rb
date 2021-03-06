# This administrative controller sets defaults for the other administrative
# controllers. It is intended as an abstract class for other admin controllers
# to inherit.
class Admin::AdminController < ApplicationController
  # Override non-JS DELETE hyprlinks fallback for admin pages.
  skip_before_filter :confirm_destroy

  skip_before_filter :find_context_node

  # Don't set search scopes in backend
  skip_before_filter :set_search_scopes

  skip_before_filter :set_private_menu

  skip_before_filter :find_accessible_content_children_for_menu

  skip_before_filter :set_page_title

  skip_before_filter :set_rss_feed_url

  skip_before_filter :check_authorization

  # Require the user to be logged in for all actions.
  before_filter :login_required

  # Require users to have at least one of the roles +admin+, +final_editor+ and
  # +editor+.
  require_role %w(admin final_editor editor), any_node: true

  # Set the action buttons for the +show+ and +previous+ actions.
  before_filter :set_actions, only: [:show, :previous]

  before_filter :set_for_approval, only: [:edit, :update]

  # Skip the filter that increments the hits for nodes
  skip_after_filter :increment_hits

  # Politely ask browsers to not cache anything in the admin namespace..
  before_filter :set_cache_buster, only: [:show, :edit, :update, :previous, :import, :build]

  layout :layout?

  helper Admin::NewsletterArchiveHelper, Admin::AgendaItemsHelper, Admin::AdminHelper, Admin::AdminFormBuilderHelper, Admin::DiffHelper, Admin::CropperHelper

  cache_sweeper :node_sweeper, only: [:create, :update, :destroy, :approve, :set_visibility, :set_accessibility, :move, :bulk_update, :bulk_destroy, :sort_children]

  protected

  def default_format_json
    if request.headers['HTTP_ACCEPT'].nil? && params[:format].nil?
      request.format = 'json'
    end
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def find_node
    return unless params[:id].present? && controller_model.respond_to?(:is_content_node?) && controller_model.is_content_node?
    @node = Node.include_content.where(['content_type = ? AND content_id = ?', controller_model.base_class.name, params[:id]]).first!
  end

  # Finds the Node object corresponding to the passed in +parent_node_id+ parameter.
  def find_parent_node
    @parent_node ||= Node.find(params[:parent_node_id]) if params[:parent_node_id]
  end

  def find_children
    @children = (@calendar_item || @meeting).node.children.accessible.exclude_content_types(%w( Image Attachment ContentCopy )).include_content.map(&:content)
    find_images_and_attachments
  end

  # Don't render the response in a layout for XHR requests
  def layout?
    if request.xhr?
      return false
    else
      return 'admin'
    end
  end

  # Handles response when access has been denied
  def access_denied
    if logged_in?
      flash[:notice] = I18n.t('application.not_authorized')
      respond_to do |f|
        f.html do
          unless request.xhr?
            redirect_to current_user.has_any_role? ? admin_nodes_path : root_path
          else
            render text: flash[:notice], status: :forbidden # Render HTML
          end
        end
        f.js do
          render :update do |page|
            page.redirect_to '/admin' # Redirect through JS
          end
        end
        f.json do
          render json: { error: flash[:notice] }.to_json, status: :forbidden
        end
      end
    else
      super
    end
  end

  # Finds paging parameters and configures the current page.
  def set_paging
    if extjs_paging?
      offset        = params[:start].to_i
      @page_limit   = params[:limit].to_i
      @current_page = (offset / @page_limit) + 1 # start at page 1
    else
      @page_limit   = 20 # sync with ExtJS PagingToolbar configuration in view!
      @current_page = 1
    end
  end

  # Returns true if we have received ExtJS PagingToolbar parameters.
  def extjs_paging?
    params[:limit] && params[:start]
  end

  # Returns true if we have received ExtJS Store sorting.
  def extjs_sorting?
    params[:sort] && params[:dir]
  end

  # Helper method for parsing dates corresponding to the passed in +year+ and/or +month+ parameters.
  def parse_date_parameters
    if params[:year] && params[:month]
      date   = Date.civil(params[:year].to_i, params[:month].to_i) rescue nil
      if date
        @year  = date.year
        @month = date.month
      end
    elsif params[:year]
      date  = Date.civil(params[:year].to_i) rescue nil
      @year = date.year if date
    end
  end

  # Sets the button bar for show and previous actions.
  def set_actions
    @actions = []

    unless params[:show_actions] == 'false' || @node.blank?
      role = current_user.role_on(@node)

      if role && @node.content_type_configuration[:allowed_roles_for_update].include?(role.name)
        @actions << { url: { action: :edit }, text: I18n.t('admin.edit'), method: :get }
      end
    end
  end

  def set_commit_type
    @commit_type = params[:commit_type] || 'save'
  end

  def set_for_approval
    @for_approval = (params.has_key?('for_approval') and params['for_approval'] != 'false') ? true : false
  end

  def set_page_title
    # do nothing
  end

  def parse_start_and_end_times
    type = if params.has_key?(:calendar_item)
      :calendar_item
    elsif params.has_key?(:meeting)
      :meeting
    end

    if type.present?
      params[type][:start_time] = Time.parse(params[type].delete(:start_time)) rescue nil if params[type][:start_time].present?
      params[type][:end_time]   = Time.parse(params[type].delete(:end_time))   rescue nil if params[type][:end_time].present?
      params[type][:date]       = Date.parse(params[type].delete(:date))       rescue nil if params[type][:date].present?
    end
  end

  def item_sortlet_hash_for_ids(sortlet_item_ids)
    return if sortlet_item_ids.blank?

    sortlet_item_ids.map do |item_sortlet_id|
      item_sortlet_hash(Node.find(item_sortlet_id))
    end
  end

  def item_sortlet_hash(node)
    {
      title:          node.content.title,
      id:             node.id,
      nodeId:         node.id,
      controllerName: node.content.controller_name,
      contentNodeId:  node.content_id,
      xtype:          'sortlet'
    }
  end

  # Overrides the +ssl_required?+ method in the +ApplicationController+.
  # We always want ssl enabled for the admin interface, if it is available,
  # as it ensures we can redirect properly on invalid logins.
  def ssl_required?
    !disable_ssl?
  end
end
