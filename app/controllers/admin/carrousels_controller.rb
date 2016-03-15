# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Carrousel+ objects.
class Admin::CarrouselsController < Admin::AdminController
  # The +show+, +new+, +edit+, +update+ and +create+ actions need a parent +Node+ object.
  before_filter :find_parent_node,             only: [:new, :create]

  # The +show+, +edit+ and +update+ actions need a +Carrousel+ object to act upon.
  before_filter :find_carrousel,               only: [:show, :edit, :update]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, only: [:create, :update]

  before_filter :set_commit_type,              only: [:create, :update]

  before_filter :get_item_ids,                 only: [:create, :update]

  layout false

  require_role ['admin'], except: [:show]

  # * GET /admin/carrousels/:id
  # * GET /admin/carrousels/:id.xml
  def show
    @animation = Carrousel::ANIMATION_NAMES[@carrousel.animation]

    respond_to do |format|
      format.html { render partial: 'show', locals: { record: @carrousel }, layout: 'admin/admin_show' }
      format.xml  { render xml: @carrousel }
    end
  end

  # * GET /admin/carrousels/new
  def new
    @carrousel = Carrousel.new(permitted_attributes)

    if params[:items]
      @item_sortlets = item_sortlet_hash_for_ids(params[:items], params[:carrousel_items])
    else
      @item_sortlets = []
    end
  end

  # * GET /admin/carrousels/:id/edit
  def edit
    @carrousel.attributes = permitted_attributes

    if params[:items]
      @item_sortlets = item_sortlet_hash_for_ids(params[:items], params[:carrousel_items])
    else
      @item_sortlets = @carrousel.carrousel_items.map do |carrousel_item|
        item_sortlet_hash(carrousel_item.item, carrousel_item.excerpt)
      end
    end
  end

  # * POST /admin/carrousels/create
  # * POST /admin/carrousels/create.xml
  def create
    @carrousel        = Carrousel.new(permitted_attributes)
    @carrousel.parent = @parent_node
    @carrousel.associate_items(@item_ids, @carrousel_items)

    respond_to do |format|
      if @commit_type == 'preview' && @carrousel.valid?
        format.html { render template: 'admin/shared/create_preview', locals: { record: @carrousel }, layout: 'admin/admin_preview' }
        format.xml  { render xml: @carrousel, status: :created, location: @carrousel }
      elsif @commit_type == 'save' && @carrousel.save(user: current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render xml: @carrousel, status: :created, location: @carrousel }
      else
        @item_sortlets = item_sortlet_hash_for_ids(@item_ids, @carrousel_items)
        format.html { render action: :new }
        format.xml  { render xml: @carrousel.errors.to_xml, status: :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/carrousels/update/:id
  # * PUT /admin/carrousels/update/:id.xml
  def update
    @carrousel.attributes = permitted_attributes
    @carrousel.associate_items(@item_ids, @carrousel_items)

    respond_to do |format|
      if @commit_type == 'preview' && @carrousel.valid?
        format.html { render template: 'admin/shared/update_preview', locals: { record: @carrousel }, layout: 'admin/admin_preview' }
        format.xml  { render xml: @carrousel, status: :created, location: @carrousel }
      elsif @commit_type == 'save' && @carrousel.save(user: current_user)
        format.html do
          @refresh = true
          render template: 'admin/shared/update'
        end
        format.xml  { head :ok }
      else
        @item_sortlets = item_sortlet_hash_for_ids(@item_ids)
        format.html { render action: :edit, status: :unprocessable_entity }
        format.xml  { render xml: @carrousel.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def permitted_attributes
    params.fetch(:carrousel, {}).permit!
  end

  # Finds the +Carrousel+ object corresponding to the passed in +id+ parameter.
  def find_carrousel
    @carrousel = Carrousel.includes(:node).find(params[:id]).current_version
  end

  def get_item_ids
    @item_ids        = params[:items]           || []
    @carrousel_items = params[:carrousel_items] || []
  end

  def get_approved_content_items
    @approved_content_items = @item_ids.map do |item_id|
      Node.find(item_id).content
    end
  end

  def item_sortlet_hash_for_ids(sortlet_item_ids, carrousel_items = {})
    carrousel_items ||= {}

    if sortlet_item_ids.present?
      sortlet_item_ids.map do |item_sortlet|
        element = Node.find(item_sortlet).content
        item_sortlet_hash(element, carrousel_items[item_sortlet])
      end
    end
  end

  def item_sortlet_hash(element, excerpt = '')
    if element.node.content_type == 'Image'
      image = element.node
    else
      image = element.node.children.with_content_type('Image').first
    end

    html = ''
    html << "<img src=\"/#{image.url_alias}/thumbnail.jpg\"/>" if image.present?
    html << "<textarea rows=\"10\" cols=\"50\" id=\"carrousel_items[#{element.node.id}]\" name=\"carrousel_items[#{element.node.id}]\">#{excerpt}</textarea>"
    {
      title:          element.title,
      id:             element.node.id,
      nodeId:         element.node.id,
      controllerName: element.class.name.tableize,
      contentNodeId:  element.id,
      xtype:          'sortlet',
      html:           html
    }
  end
end
