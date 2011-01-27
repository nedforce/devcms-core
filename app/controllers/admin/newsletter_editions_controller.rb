# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsletterEdition+ objects.
class Admin::NewsletterEditionsController < Admin::AdminController

  # The +show+, +new+, +edit+, +update+ and +create+ actions need a parent +Node+ object.
  prepend_before_filter :find_parent_node,     :only => [ :new, :create ]

  # The +show+, +edit+, +create+ and +update+ actions need a +NewsletterArchive+ object to act upon.
  before_filter :find_newsletter_archive,      :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +NewsletterEdition+ object to act upon.
  before_filter :find_newsletter_edition,      :only => [ :show, :edit, :update, :previous ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :create, :update ]

  before_filter :find_images_and_attachments,  :only => [ :show, :previous ]

  before_filter :set_commit_type,              :only => [ :create, :update ]

  before_filter :get_item_ids,                 :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ] , :for_all_except => [ :show ]

  # * GET /admin/newsletter_editions/:id
  # * GET /admin/newsletter_editions/:id.xml
  def show
    @approved_content_items = @newsletter_edition.approved_items

    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @newsletter_edition }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @newsletter_edition }
    end
  end

  # * GET /admin/newsletter_edition/:id/previous
  # * GET /admin/newsletter_edition/:id/previous.xml
  def previous
    @newsletter_edition = @newsletter_edition.previous_version
    show
  end

  # * GET /admin/newsletter_editions/new
  def new
    @newsletter_edition = @newsletter_archive.newsletter_editions.build(params[:newsletter_edition])

    if params[:items]
      @item_sortlets = item_sortlet_hash_for_ids(params[:items])
    else
      @item_sortlets = []
    end
  end

  # * GET /admin/newsletter_editions/:id/edit
  def edit
    @newsletter_edition.attributes = params[:newsletter_edition]

    if params[:items]
      @item_sortlets = item_sortlet_hash_for_ids(params[:items])
    else
      @item_sortlets = @newsletter_edition.items.map { |item| item_sortlet_hash(item.node) }
    end
  end

  # * POST /admin/newsletter_editions/create
  # * POST /admin/newsletter_editions/create.xml
  def create
    @newsletter_edition        = @newsletter_archive.newsletter_editions.build(params[:newsletter_edition])
    @newsletter_edition.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @newsletter_edition.valid?
        get_approved_content_items
        format.html { render :action => 'create_preview', :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @newsletter_edition, :status => :created, :location => @newsletter_edition }
      elsif @commit_type == 'save' && @newsletter_edition.save_for_user(current_user)
        # Add the items to the edition (if any)
        @newsletter_edition.associate_items(@item_ids)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @newsletter_edition, :status => :created, :location => @newsletter_edition }
      else
        @item_sortlets = item_sortlet_hash_for_ids(@item_ids)
        format.html { render :action => :new }
        format.xml  { render :xml => @newsletter_edition.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/newsletter_editions/update/:id
  # * PUT /admin/newsletter_editions/update/:id.xml
  def update
    @newsletter_edition.attributes = params[:newsletter_edition]

    respond_to do |format|
      if @commit_type == 'preview' && @newsletter_edition.valid?
        format.html do
          get_approved_content_items
          find_images_and_attachments
          render :action => 'update_preview', :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @newsletter_edition, :status => :created, :location => @newsletter_edition }
      elsif @commit_type == 'save' && @newsletter_edition.save_for_user(current_user, @for_approval)
        # Replace the items for the edition (if any)
        @newsletter_edition.associate_items(@item_ids)
        format.html {
          @refresh = true
          render :template => 'admin/shared/update'
        }
        format.xml  { head :ok }
      else
        @item_sortlets = item_sortlet_hash_for_ids(@item_ids)
        format.html { render :action => :edit }
        format.xml  { render :xml => @newsletter_edition.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +NewsletterArchive+ object corresponding to the parent node's content.
  def find_newsletter_archive
    @newsletter_archive = @parent_node.content
  end

  # Finds the +NewsItem+ object corresponding to the passed in +id+ parameter.
  def find_newsletter_edition
    @newsletter_edition = ((@newsletter_archive) ? @newsletter_archive.newsletter_editions : NewsletterEdition).find(params[:id], :include => :node)
  end

  def get_item_ids
    @item_ids = params[:items] || []
  end

  def get_approved_content_items
    @approved_content_items = @item_ids.map do |item_id|
      Node.find(item_id).approved_content
    end
  end
end
