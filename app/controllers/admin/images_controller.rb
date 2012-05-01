class Admin::ImagesController < Admin::AdminController

  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  before_filter :find_sibling_images,      :only => [ :new, :create ]

  before_filter :find_image,             :except => [ :new, :create ]
  
  before_filter :find_node,                :only => [ :update, :destroy, :edit, :show, :preview, :thumbnail, :thumbnail_preview, :content_box_header_preview, :previous ]

  before_filter :clean_is_for_header,      :only => [ :create, :update ]

  require_role [ 'admin', 'final_editor', 'editor' ]

  layout false

  # * GET /admin/images/:id
  # * GET /admin/images/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @image }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @image }
    end
  end

  # * GET /admin/images/:id/previous
  # * GET /admin/images/:id/previous.xml
  def previous
    @image = @image.previous_version
    show
  end

  # * GET /admin/images/:id/preview.jpg
  def preview
    render_jpg_image_data @image.resize!(:size => '800x500', :format => 'jpg')
  end

  # * GET /admin/images/:id/thumbnail.jpg
  def thumbnail
    render_jpg_image_data @image.resize!(:size => '100x100', :format => 'jpg')
  end

  def thumbnail_preview
    if @image.orientation == :vertical 
      render_jpg_image_data @image.resize!(:size => "100x", :upsample => true, :quality => 80, :format => 'jpg')
    else
      render_jpg_image_data @image.resize!(:size => [nil, 100], :upsample => true, :quality => 80, :format => 'jpg')
    end
  end
  
  def content_box_header_preview
    render_jpg_image_data @image.resize!(:size => "#{Image::CONTENT_BOX_SIZE[:width]}x", :upsample => true, :quality => 80, :format => 'jpg')
  end

  # * GET /admin/images/new
  def new
    @image = Image.new
    @image.parent           = @parent_node    
    @show_image_url_control = can_set_image_url?
  end

  # * GET /admin/images/:id/edit
  def edit
    @show_image_url_control = can_set_image_url?
  end

  # * POST /admin/images
  # * POST /admin/images.js
  # * POST /admin/images.xml
  def create
    @image                  = Image.new(params[:image])
    @image.parent           = @parent_node
    @show_image_url_control = can_set_image_url?
    @image.url              = nil if !@show_image_url_control

    respond_to do |format|
      if @image.save(:user => current_user)

        format.html # create.html.erb
        format.xml  { render :xml => @image, :status => :created, :location => @image }
        format.js do
          responds_to_parent do |page|
            page << "if(Ext.get('no_images_row')) Ext.get('no_images_row').remove();"
            
            if current_user.has_role?('admin')
              page.insert_html(:bottom, "uploaded_images", "<tr id=\"uploaded_image_#{@image.id}\">
                <td>#{h(@image.title)}</td>
                <td>#{image_tag(thumbnail_admin_image_path(@image, :format => :jpg), :alt => h(@image.alt))}</td>
                <td>#{check_box_tag("image_is_for_header_#{@image.id}", "1", @image.is_for_header?, :onchange => "this.disable();" + remote_function(:url => admin_image_path(@image, :format => :jpg), :method => :put, :complete => "$('image_is_for_header_#{@image.id}').enable();", :with => "'image[is_for_header]='+$F('image_is_for_header_#{@image.id}')")+"; return false;")}</td>
                <td><div id='image_cropper_#{@image.id}'></div> </td>
              </tr>")
            else
              page.insert_html(:bottom, "uploaded_images", "<tr id=\"uploaded_image_#{@image.id}\">
                <td>#{h(@image.title)}</td>
                <td>#{image_tag(thumbnail_admin_image_path(@image, :format => :jpg), :alt => h(@image.alt))}</td>
                <td><div id='image_cropper_#{@image.id}'></div> </td>
              </tr>")           
            end
            
            page.call("treePanel.refreshNodesOf", @parent_node.id)
            page.replace_html("image_cropper_#{@image.id}", :partial => "cropper_#{@image.orientation}", :locals => { :image => @image })
            
            @image = Image.new # To reset fields
            page.replace_html("right_panel_form", :partial => 'form')
          end
        end
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
        format.js do
          responds_to_parent do |page|
            # rerender form with error messages:
            page.replace_html("right_panel_form", :partial => 'form')
          end
        end
      end
    end
  end

  # * PUT /admin/images/:id
  # * PUT /admin/images/:id.xml
  def update
    @show_image_url_control = can_set_image_url?
    params[:image].delete(:url) if !@show_image_url_control
    @image.attributes = params[:image]

    respond_to do |format|
      if @image.save(:user => current_user, :approval_required => @for_approval)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit', :status => :unprocessable_entity }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

    def find_image
      @image = Image.find(params[:id])
    end

    def find_sibling_images
      @sibling_images = Image.accessible.all(:conditions => ["nodes.ancestry = :parent_child_ancestry", {:parent_child_ancestry => @parent_node.child_ancestry }])
    end

    def render_jpg_image_data(image_data)
      respond_to do |format|
        format.any do
          send_data(image_data, :type => 'image/jpeg', :disposition => 'inline')   
        end      
      end
    end

    def can_set_image_url?
      current_user_is_admin?(@image.node) || current_user_is_final_editor?(@image.node)
    end

    def clean_is_for_header
      if params[:image] && !current_user.has_role?('admin')
        params[:image].delete(:is_for_header)
      end
    end
end
