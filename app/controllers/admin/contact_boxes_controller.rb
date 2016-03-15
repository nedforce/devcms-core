# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +ContactBox+ objects.
class Admin::ContactBoxesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +ContactBox+ content node to.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +ContactBox+ object to act upon.
  before_filter :find_contact_box, :only => [ :show, :edit, :update ]

  layout false

  require_role [ 'admin' ]

  # * GET /contact_boxes/:id
  # * GET /contact_boxes/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @contact_box }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @contact_box }
    end
  end

  # * GET /admin/contact_boxes/new
  def new
    @contact_box = ContactBox.new(permitted_attributes)

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @contact_box } }
    end
  end

  # * GET /admin/contact_boxes/:id/edit
  def edit
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @contact_box } }
    end
  end

  # * POST /admin/contact_boxes
  # * POST /admin/contact_boxes.xml
  def create
    @contact_box        = ContactBox.new(permitted_attributes)
    @contact_box.parent = @parent_node

    respond_to do |format|
      if @contact_box.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @contact_box }, :status => :unprocessable_entity }
        format.xml  { render :xml => @contact_box.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/contact_boxs/:id
  # * PUT /admin/contact_boxs/:id.xml
  def update
    @contact_box.attributes = permitted_attributes

    respond_to do |format|
      if @contact_box.save(:user => current_user)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @contact_box }, :status => :unprocessable_entity }
        format.xml  { render :xml => @contact_box.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def permitted_attributes
    params.fetch(:contact_box, {}).permit!
  end

  # Finds the +ContactBox+ object corresponding to the passed in +id+ parameter.
  def find_contact_box
    @contact_box = ContactBox.find(params[:id]).current_version
  end
end
