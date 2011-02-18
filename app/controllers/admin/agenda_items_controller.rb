# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to AgendaItem objects.
class Admin::AgendaItemsController < Admin::AdminController

  # Only the +new+ and +create+ actions need a parent Node object.
  prepend_before_filter :find_parent_node,    :only => [ :new, :create ]

  # The +new+ and +create+ actions need a Meeting object to act upon.
  before_filter :find_meeting,                :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need an AgendaItem object to act upon.
  before_filter :find_agenda_item,            :only => [ :show, :edit, :update, :previous ]

  # Find the child nodes for the +show+ and +previous+ actions.
  before_filter :find_images_and_attachments, :only => [ :show, :previous ]

  before_filter :set_commit_type,             :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /admin/agenda_items/:id
  # * GET /admin/agenda_items/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @agenda_item }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @agenda_item }
    end
  end 

  # * GET /admin/agenda_items/:id/previous
  # * GET /admin/agenda_items/:id/previous.xml
  def previous
    @agenda_item = @agenda_item.previous_version
    show
  end

  # * GET /admin/agenda_items/new
  def new
    find_agenda_item_categories
    build_speaking_right_options
    @agenda_item = @meeting.agenda_items.build(params[:agenda_item])
    
    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @agenda_item }}
    end
  end

  # * GET /admin/agenda_items/:id/edit
  def edit
    find_agenda_item_categories
    build_speaking_right_options
    @agenda_item.attributes = params[:agenda_item]
    
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @agenda_item }}
    end
  end

  # * POST /admin/agenda_items
  # * POST /admin/agenda_items.xml
  def create
    @agenda_item        = @meeting.agenda_items.build(params[:agenda_item])    
    @agenda_item.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @agenda_item.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @agenda_item }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @agenda_item, :status => :created, :location => @agenda_item }
      elsif @commit_type == 'save' && @agenda_item.save_for_user(current_user)
        format.html do
          if params[:continue].present?
            find_agenda_item_categories
            build_speaking_right_options
            @agenda_item = @meeting.agenda_items.build
            render :template => 'admin/shared/new', :locals => { :record => @agenda_item }, :status => :success
          else
            render :template => 'admin/shared/create'
          end
        end
        format.xml  { render :xml => @agenda_item, :status => :created, :location => @agenda_item }
      else
        format.html do 
          find_agenda_item_categories
          build_speaking_right_options
          render :template => 'admin/shared/new', :locals => { :record => @agenda_item }, :status => :unprocessable_entity
        end
        format.xml  { render :xml => @agenda_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/agenda_items/:id
  # * PUT /admin/agenda_items/:id.xml
  def update
    @agenda_item.attributes = params[:agenda_item]

    respond_to do |format|
      if @commit_type == 'preview' && @agenda_item.valid?
        format.html do
          find_images_and_attachments
          render :template => 'admin/shared/update_preview', :locals => { :record => @agenda_item }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @agenda_item, :status => :created, :location => @agenda_item }
      elsif @commit_type == 'save' && @agenda_item.save_for_user(current_user, @for_approval)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html do 
          find_agenda_item_categories
          build_speaking_right_options
          render :template => 'admin/shared/edit', :locals => { :record => @agenda_item }, :status => :unprocessable_entity
        end
        format.xml  { render :xml => @agenda_item.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the Meeting object corresponding to the parent node's content.
  def find_meeting
    @meeting = @parent_node.content
  end

  # Finds the AgendaItem object corresponding to the passed in +id+ parameter.
  def find_agenda_item
    @agenda_item = ((@meeting) ? @meeting.agenda_items : AgendaItem).find(params[:id], :include => :node)
  end

  # Finds all AgendaItemCategory objects.
  def find_agenda_item_categories
    @categories = AgendaItemCategory.all(:order => 'name')
  end

  # Builds an array for selection fields that select a speaking right option.
  def build_speaking_right_options
    @speaking_right_options = AgendaItem::SPEAKING_RIGHT_OPTIONS.map { |k, v| [ I18n.t("calendars.speaking_rights_#{v}"), k ]}.unshift([ '', nil ])
  end  
end
