# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +AlphabeticIndex+ objects.
class Admin::AlphabeticIndicesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +AlphabeticIndex+ content node to.
  prepend_before_filter :find_parent_node, :only => [:new, :create ]

  # The +show+, +edit+ and +update+ actions need an +AlphabeticIndex+ object to act upon.
  before_filter :find_alphabetic_index,    :only => [ :show, :edit, :update ]

  layout false

  require_role [ 'admin' ], :except => [ :show ]

  # * GET /alhpabetic_indices/:id
  # * GET /alphabetic_indices/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @alphabetic_index }
    end
  end

  # * GET /admin/alphabetic_indices/new
  def new
    @alphabetic_index = AlphabeticIndex.new(params[:alphabetic_index])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @alphabetic_index }}
    end
  end

  # * GET /admin/alphabetic_indices/:id/edit
  def edit
    @alphabetic_index.attributes = params[:alphabetic_index]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @alphabetic_index }}
    end
  end

  # * POST /admin/alphabetic_indices
  # * POST /admin/alphabetic_indices.xml
  def create
    @alphabetic_index        = AlphabeticIndex.new(params[:alphabetic_index])
    @alphabetic_index.parent = @parent_node

    respond_to do |format|
      if @alphabetic_index.save
        format.html { render :template => 'admin/shared/create' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @alphabetic_index }, :status => :unprocessable_entity }
        format.xml  { render :xml => @alphabetic_index.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/alphabetic_indices/:id
  # * PUT /admin/alphabetic_indices/:id.xml
  def update
    @alphabetic_index.attributes = params[:alphabetic_index]

    respond_to do |format|
      if @alphabetic_index.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @alphabetic_index }, :status => :unprocessable_entity }
        format.xml  { render :xml => @alphabetic_index.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  # Finds the +AlphabeticIndex+ object corresponding to the passed in +id+ parameter.
  def find_alphabetic_index
    @alphabetic_index = AlphabeticIndex.find(params[:id]).current_version
  end
end
