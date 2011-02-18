# This administrative controller sets defaults for the other administrative
# controllers. It is intended as an abstract class for other admin controllers
# to inherit.
class Admin::AdminController < ApplicationController
  
  # Try retrieve the +Node+ object for the current request.
  # This needs to be done before any authorisation attempts, a +Node+ might be needed.
  before_filter :find_node, :only => [:show, :edit, :update, :previous]

  # Override non-JS DELETE hyprlinks fallback for admin pages.
  skip_before_filter :confirm_destroy

  # Don't set search scopes in backend
  skip_before_filter :set_search_scopes

  # Require the user to be logged in for all actions.
  before_filter :login_required

  # Require users to have at least one of the roles +admin+, +final_editor+ and +editor+.
  require_role [ 'admin', 'final_editor', 'editor' ], :any_node => true

  # Set the action buttons for the +show+ and +previous+ actions.
  before_filter :set_actions,               :only => [ :show, :previous ]

  before_filter :set_for_approval,          :only => [ :edit, :update ]

  before_filter :parse_category_parameters, :only => [:create, :update, :bulk_update ]

  # Skip the filter that increments the hits for nodes
  skip_after_filter :increment_hits

  # Expire the main menu fragment cache.
  after_filter :expire_changes_cache

  layout :layout?
  
  helper Admin::PermitsHelper, Admin::NewsletterArchiveHelper, Admin::AgendaItemsHelper, Admin::AdminHelper, Admin::AdminFormBuilderHelper, Admin::CategoriesHelper, Admin::DiffHelper

protected

  def expire_changes_cache
    expire_page("/sitemap/changes.atom") unless request.get?
  end

  # TODO: filter on user
  def find_available_templates_for(user)
    Template.all(:order => :title)
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
            render :text => flash[:notice], :status => :forbidden # Render HTML
          end
        end
        f.js do
          render :update do |page|
            page.redirect_to '/admin' # Redirect through JS
          end
        end
        f.json do
          render :json => { :error => flash[:notice] }.to_json, :status => :forbidden
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
      @year  = date.year  if date
      @month = date.month if date
    elsif params[:year]
      date  = Date.civil(params[:year].to_i) rescue nil
      @year = date.year if date
    end
  end

  # Sets the button bar for show and previous actions.
  def set_actions
    @actions = []

    unless params[:show_actions] && params[:show_actions] == 'false'
      @actions << { :url => { :action => :edit }, :text => I18n.t('admin.edit'), :method => :get } if current_user.has_any_role?
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
  
  def parse_category_parameters
    model_name = controller_name.singularize.to_sym
    params[model_name] ||= {}
    params[model_name][:category_ids]        = params[:category_ids]  || [] if params[:has_categories].present?
    params[model_name][:category_attributes] = params[:category_attributes] if params[:has_categories].present? && params[:category_attributes].present?
  end

  def parse_start_and_end_times
    type = case
    when params[:calendar_item].present?
      :calendar_item
    when params[:meeting].present?
      :meeting
    end
    if type.present?
      params[type][:start_time] = Time.parse(params[type].delete(:start_time)) rescue nil if params[type][:start_time].present?
      params[type][:end_time]   = Time.parse(params[type].delete(:end_time))   rescue nil if params[type][:end_time].present?  
      params[type][:date]       = Date.parse(params[type].delete(:date))       rescue nil if params[type][:date].present?
    end
  end

  def find_children
    @children = (@calendar_item || @meeting).accessible_children_for(current_user)
    find_images_and_attachments
  end

  def item_sortlet_hash_for_ids(sortlet_item_ids)
    if sortlet_item_ids.present?
      sortlet_item_ids.map do |item_sortlet_id|
        item_sortlet_hash(Node.find(item_sortlet_id))
      end
    end
  end

  def item_sortlet_hash(node)
    {
      :title          => node.content.title,
      :id             => node.id,
      :nodeId         => node.id,
      :controllerName => node.content_type_configuration[:controller_name] || node.content_class.table_name,
      :contentNodeId  => node.content_id,
      :xtype          => 'sortlet'
    }
  end
end
