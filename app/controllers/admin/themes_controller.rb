# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Theme+ objects.

class Admin::ThemesController < Admin::AdminController
  # The +create+ action needs the parent +Node+ object to link the new +Theme+ content node to.
  prepend_before_filter :find_parent_node,    :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +Theme+ object to act upon.
  before_filter         :find_theme,          :only => [ :show, :edit, :update ]

  # Set the subclass of +Theme+ to create based on the parent node
  before_filter         :set_subclass,        :only => [ :new, :create, :edit, :update ]

  before_filter         :set_commit_type,     :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ], :except => [ :index, :show ]

  # * GET /admin/themes/:id
  # * GET /admin/themes/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @theme }
    end
  end
  
  # * GET /admin/themes/new
  def new
    @theme = @subclass.new(params[@type])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @theme } }
    end
  end

  # * GET /admin/themes/:id/edit
  def edit
    @theme.attributes = params[@type]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @theme } }
    end
  end

  # * POST /admin/themes
  # * POST /admin/themes.xml
  def create
    @theme        = @subclass.new(params[@type])
    @theme.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @theme.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @theme }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @theme, :status => :created, :location => @theme }
      elsif @commit_type == 'save' && @theme.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render :xml => @theme, :status => :created, :location => @theme }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @theme }, :status => :unprocessable_entity }
        format.xml  { render :xml => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # * PUT /admin/themes/:id
  # * PUT /admin/themes/:id.xml
  def update
    @theme.attributes = params[@type]

    respond_to do |format|
      if @commit_type == 'preview' && @theme.valid?
        format.html { render :template => 'admin/shared/update_preview', :locals => { :record => @theme }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @theme, :status => :created, :location => @theme }
      elsif @commit_type == 'save' && @theme.save(:user => current_user)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @theme }, :status => :unprocessable_entity }
        format.xml  { render :xml => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Theme+ object corresponding to the passed in +id+ parameter.
  def find_theme
    @theme = Theme.find(params[:id], :include => [ :node ]).current_version
  end

  def set_subclass
    @type     = params[:type]
    @subclass = @type.classify.constantize
  end
end
