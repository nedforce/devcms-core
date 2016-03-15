# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Section+ objects.
class Admin::SectionsController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +Page+ content node to.
  prepend_before_filter :find_parent_node,     :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +Section+ object to act upon.
  before_filter :find_section,                 :only => [ :show, :previous, :edit, :update, :send_expiration_notifications, :import, :build ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :create, :update ]

  before_filter :find_images_and_attachments,  :only => [ :show, :previous ]

  before_filter :find_children,                :only => [ :show, :previous ]

  before_filter :set_commit_type,              :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /admin/sections/:id
  # * GET /admin/sections/:id.xml
  def show
    @actions << { :url => { :action => :send_expiration_notifications }, :text => I18n.t('sections.send_expiration_notifications') } if current_user_is_admin?(@node) || current_user_is_final_editor?(@node)
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @section }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @section }
    end
  end

  # * GET /admin/sections/:id/previous
  # * GET /admin/sections/:id/previous.xml
  def previous
    @section = @section.previous_version
    show
  end

  # * GET /admin/sections/new
  def new
    @section = Section.new(permitted_attributes)
    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @section } }
    end
  end

  # * GET /admin/sections/:id/edit
  def edit
    @show_frontpage_control = can_set_frontpage?
    @section.attributes     = permitted_attributes
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @section } }
    end
  end

  # * POST /admin/sections
  # * POST /admin/pages/sections.xml
  def create
    @section        = Section.new(permitted_attributes)
    @section.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @section.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @section }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      elsif @commit_type == 'save' && @section.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @section }, :status => :unprocessable_entity }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/sections/:id
  # * PUT /admin/sections/:id.xml
  def update
    @show_frontpage_control = can_set_frontpage?
    params[:section].delete(:frontpage_node_id) if !@show_frontpage_control
    @section.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @section.valid?
        format.html do
          find_images_and_attachments
          find_children
          render :template => 'admin/shared/update_preview', :locals => { :record => @section }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      elsif @commit_type == 'save' && @section.save(:user => current_user, :approval_required => @for_approval)
        format.html # update.html.erb
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @section }, :status => :unprocessable_entity }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  def send_expiration_notifications
    NodeExpirationMailerWorker.notify_authors(@section.node)
    render :text => '<div class="rightPanelDefault" id="rightPanelDefault"><table><tr><td>' + t('sections.expiration_notification_sent') + '</td></tr></table></div>'
  end

  def import
    respond_to do |format|
      format.html { render :layout => 'admin/admin_blank' }
    end
  end

  def build
    importer = Importer.import!(params[:data], @section)

    if importer.success?
      flash.now[:notice] = "#{importer.instances.size} content items aangemaakt."
    else
      flash.now[:notice] = "Importeren mislukt. Controleer het formaat van het opgegeven bestand en probeer opnieuw. Foutmelding: '#{importer.errors.join(', ')}'."
    end

    respond_to do |format|
      format.js do
        responds_to_parent do |page|
          page.call('treePanel.refreshNodesOf', @section.node.id)
          page.replace_html('import_form', :partial => 'import_form')
        end
      end
    end
  end

protected

  def permitted_attributes
    params.fetch(:section, {}).permit!
  end

  # Retrieves the requested +Section+ object using the passed in +id+ parameter.
  def find_section
    @section = Section.includes(:node).find(params[:id]).current_version
  end

  def find_children
    @children = @section.node.children.accessible.is_public.exclude_content_types(%w( Image Attachment SearchPage Site )).include_content.map(&:content)
  end

  def can_set_frontpage?
    current_user_is_admin?(@section.node) || current_user_is_final_editor?(@section.node)
  end
end
