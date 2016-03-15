# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to administering +ContactForm+ objects.
class Admin::ContactFormsController < Admin::AdminController
  # The +create+ action needs the parent +Node+ object to link the new
  # +ContactForm+ content node to.
  prepend_before_filter :find_parent_node, only: [:new, :create]

  # The +show+, +edit+ and +update+ actions need a +ContactForm+ object to act
  # upon.
  before_filter :find_contact_form, only: [:show, :edit, :update]

  before_filter :set_commit_type, only: [:create, :update]

  layout false

  # * GET /admin/contact_forms/:id
  # * GET /admin/contact_forms/:id.xml
  def show
    @actions << { url: { action: :index,      controller: :responses, contact_form_id: @contact_form.id }, text: t('contact_forms.responses'),  method: :get }
    @actions << { url: { action: :upload_csv, controller: :responses, contact_form_id: @contact_form.id }, text: t('contact_forms.import_csv'), method: :get }
    respond_to do |format|
      format.html { render partial: 'show', layout: 'admin/admin_show' }
      format.xml  { render xml: @contact_form }
    end
  end

  # * GET /admin/contact_forms/new
  def new
    @contact_form = ContactForm.new(permitted_attributes)

    respond_to do |format|
      format.html { render template: 'admin/shared/new', locals: { record: @contact_form } }
    end
  end

  # * GET /admin/contact_forms/:id/edit
  def edit
    @contact_form.attributes = permitted_attributes

    respond_to do |format|
      format.html { render template: 'admin/shared/edit', locals: { record: @contact_form } }
    end
  end

  # * POST /admin/contact_forms
  # * POST /admin/contact_forms.xml
  def create
    @contact_form = ContactForm.new(permitted_attributes)
    @contact_form.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @contact_form.valid?
        format.html { render template: 'admin/shared/create_preview', locals: { record: @contact_form }, layout: 'admin/admin_preview' }
        format.xml  { render xml: @contact_form, status: :created, location: @contact_form }
      elsif @commit_type == 'save' && @contact_form.save(user: current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render xml: @contact_form, status: :created, location: @contact_form }
      else
        format.html { render template: 'admin/shared/new', locals: { record: @contact_form }, status: :unprocessable_entity }
        format.xml  { render xml: @contact_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/contact_forms/:id
  # * PUT /admin/contact_forms/:id.xml
  def update
    @contact_form.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @contact_form.valid?
        format.html { render template: 'admin/shared/update_preview', locals: { record: @contact_form }, layout: 'admin/admin_preview' }
        format.xml  { render xml: @contact_form, status: :created, location: @contact_form }
      elsif @commit_type == 'save' && @contact_form.save(user: current_user)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render template: 'admin/shared/edit', locals: { record: @contact_form }, status: :unprocessable_entity }
        format.xml  { render xml: @contact_form.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def permitted_attributes
    params.fetch(:contact_form, {}).permit!
  end

  # Finds the +ContactForm+ object corresponding to the passed +id+ parameter.
  def find_contact_form
    @contact_form = ContactForm.includes(:contact_form_fields).find(params[:id]).current_version
    @contact_form_fields = @contact_form.contact_form_fields
  end
end
