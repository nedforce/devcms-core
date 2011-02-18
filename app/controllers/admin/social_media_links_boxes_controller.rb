# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +SocialMediaLinksBox+ objects.
class Admin::SocialMediaLinksBoxesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +SocialMediaLinksBox+ content node to.
  prepend_before_filter :find_parent_node,    :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +SocialMediaLinksBox+ object to act upon.
  before_filter :find_social_media_links_box, :only => [ :show, :edit, :update ]

  before_filter :set_commit_type,             :only => [ :create, :update ]

  layout false

  require_role [ 'admin' ], :except => [ :show ]

  # * GET /admin/social_media_links_boxes/:id
  # * GET /admin/social_media_links_boxes/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @social_media_links_box }
    end
  end

  # * GET /admin/social_media_links_boxes/new
  def new
    @social_media_links_box = SocialMediaLinksBox.new(params[:social_media_links_box])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @social_media_links_box }}
    end
  end

  # * GET /admin/social_media_links_boxes/:id/edit
  def edit
    @social_media_links_box.attributes = params[:social_media_links_box]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @social_media_links_box }}
    end
  end

  # * POST /admin/social_media_links_boxes
  # * POST /admin/social_media_links_boxes.xml
  def create
    @social_media_links_box        = SocialMediaLinksBox.new(params[:social_media_links_box])
    @social_media_links_box.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @social_media_links_box.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @social_media_links_box }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @social_media_links_box, :status => :created, :location => @social_media_links_box }
      elsif @commit_type == 'save' && @social_media_links_box.save
        format.html { render :template => 'admin/shared/create' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @social_media_links_box }, :status => :unprocessable_entity }
        format.xml  { render :xml => @social_media_links_box.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/social_media_links_boxes/:id
  # * PUT /admin/social_media_links_boxes/:id.xml
  def update
    @social_media_links_box.attributes = params[:social_media_links_box]

    respond_to do |format|
      if @commit_type == 'preview' && @social_media_links_box.valid?
        format.html { render :template => 'admin/shared/update_preview', :locals => { :record => @social_media_links_box }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @social_media_links_box, :status => :created, :location => @social_media_links_box }
      elsif @commit_type == 'save' && @social_media_links_box.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @social_media_links_box }, :status => :unprocessable_entity }
        format.xml  { render :xml => @social_media_links_box.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  # Finds the +SocialMediaLinksBox+ object corresponding to the passed in +id+ parameter.
  def find_social_media_links_box
    @social_media_links_box = SocialMediaLinksBox.find(params[:id])
  end
end
