# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +FaqArchive+ objects.
class Admin::FaqArchivesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +FaqArchive+ content node to.
  prepend_before_filter :find_parent_node, :only => [:new, :create ]

  # The +show+, +edit+ and +update+ actions need a +FaqArchive+ object to act upon.
  before_filter :find_faq_archive,    :only => [ :show, :edit, :update ]

  before_filter :set_commit_type,          :only => [ :create, :update ]

  layout false

  require_role [ 'admin' ], :except => [ :show ]

  # * GET /faq_archives/:id
  # * GET /faq_archives/:id.xml
  def show       
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @faq_archive }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @faq_archive }
    end
  end  

  # * GET /admin/faq_archives/new
  def new
    @faq_archive = FaqArchive.new(params[:faq_archive])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @faq_archive }}
    end
  end
  
  # * GET /admin/faq_archives/:id/edit
  def edit
    @faq_archive.attributes = params[:faq_archive]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @faq_archive }}
    end
  end

  # * POST /admin/faq_archives
  # * POST /admin/faq_archives.xml
  def create
    @faq_archive        = FaqArchive.new(params[:faq_archive])    
    @faq_archive.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @faq_archive.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @faq_archive }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @faq_archive, :status => :created, :location => @faq_archive }
      elsif @commit_type == 'save' && @faq_archive.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @faq_archive }, :status => :unprocessable_entity }
        format.xml  { render :xml => @faq_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/faq_archives/:id
  # * PUT /admin/faq_archives/:id.xml
  def update
    @faq_archive.attributes = params[:faq_archive]

    respond_to do |format|
      if @commit_type == 'preview' && @faq_archive.valid?
        format.html do
          render :template => 'admin/shared/update_preview', :locals => { :record => @faq_archive }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @faq_archive, :status => :created, :location => @faq_archive }
      elsif @commit_type == 'save' && @faq_archive.save(:user => current_user)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @faq_archive }, :status => :unprocessable_entity }
        format.xml  { render :xml => @faq_archive.errors, :status => :unprocessable_entity }
      end
    end
  end
  protected

  # Finds the +FaqArchive+ object corresponding to the passed in +id+ parameter.
  def find_faq_archive
    @faq_archive = FaqArchive.find(params[:id]).current_version
  end
end
