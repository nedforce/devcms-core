# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to administering +ContactFormField+ objects.
class Admin::ContactFormFieldsController < Admin::AdminController

  # A +ContactFormField+ object is always associated with a +ContactForm+ object.
  before_filter :find_contact_form

  # The +show+, +edit+ and +update+ actions need a +ContactFormField+ object to act upon.
  before_filter :find_contact_form_field, :only => [ :show, :edit, :update, :destroy ]

  before_filter :set_field_types,         :only => [ :new, :edit ]

  before_filter :set_commit_type,         :only => [ :create, :update ]
  
  skip_before_filter :find_node, :only => [:edit, :update]
  
  layout false

  # * GET /admin/contact_forms/:contact_form_id/contact_form_fields/:id
  # * GET /admin/contact_forms/:contact_form_id/contact_form_fields/:id.xml
  def show
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @contact_form_field }
    end
  end

  # * GET /admin/contact_forms/:contact_form_id/contact_form_fields/new
  # * GET /admin/contact_forms/:contact_form_id/contact_form_fields/new.js
  def new
    @contact_form_field = @contact_form.contact_form_fields.new(params[:contact_form_field])

    respond_to do |format|
      format.html { render :partial => 'new' }
      format.js do
        render :update do |page|
          page.replace_html 'new_contact_form_field', :partial => 'new'
        end
      end
    end
  end

  # * GET /admin/contact_forms/:contact_form_id/contact_form_fields/:id/edit
  # * GET /admin/contact_forms/:contact_form_id/contact_form_fields/:id/edit.js
  def edit
    @contact_form_field.attributes = params[:contact_form_field]

    respond_to do |format|
      format.html { render :partial => 'edit' }
      format.js   {
        render :update do |page|
          page.replace_html "contact_form_field_#{@contact_form_field.id}", :partial => 'edit'
        end
      }
    end
  end

  # * POST /admin/contact_forms/:contact_form_id/contact_form_fields
  # * POST /admin/contact_forms/:contact_form_id/contact_form_fields.js
  # * POST /admin/contact_forms/:contact_form_id/contact_form_fields.xml
  def create
    @contact_form_field = @contact_form.contact_form_fields.new(params[:contact_form_field])

    respond_to do |format|
      if @commit_type == 'preview' && @contact_form_field.valid?
        format.html { render :action => 'create_preview', :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @contact_form_field, :status => :created, :location => @contact_form_field }
      elsif @commit_type == 'save' && @contact_form_field.valid? && @contact_form_field.save
        format.html # create.html.erb
        format.js do
          render :update do |page|
            page.replace_html 'contact_form_fields',    :partial => 'index'
            page.replace_html 'new_contact_form_field', :partial => 'new_contact_form_field'
          end
        end
        format.xml  { render :xml => @contact_form_field, :status => :created, :location => @contact_form_field }
      else
        set_field_types
        format.html { render :partial => 'new' }
        format.js do
          render :update do |page|
            page.replace_html 'new_contact_form_field', :partial => 'new'
          end
        end
        format.xml  { render :xml => @contact_form_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/contact_forms/:contact_form_id/contact_form_fields/:id
  # * PUT /admin/contact_forms/:contact_form_id/contact_form_fields/:id.xml
  def update
    @contact_form_field.attributes = params[:contact_form_field]

    respond_to do |format|
      if @commit_type == 'preview' && @contact_form_field.valid?
        format.html do
          render :action => 'update_preview', :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @contact_form_field, :status => :created, :location => @contact_form_field }
      elsif @commit_type == 'save' && @contact_form_field.save
        format.html # update.html.erb
        format.xml  { head :ok }
      else
        set_field_types
        format.html { render :partial => 'edit' }
        format.xml  { render :xml => @contact_form_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * DELETE /admin/contact_forms/:contact_form_id/contact_form_fields/:id.js
  def destroy
    @contact_form_field.destroy

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'contact_form_fields', :partial => 'index'
        end
      end
    end
  end

  def add_contact_form_field
    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'new_contact_form_field', :partial => 'new'
        end
      end
    end
  end

  protected

  # Finds the +ContactForm+ object corresponding to the passed +contact_form_id+ parameter.
  def find_contact_form
    @contact_form = ContactForm.find(params[:contact_form_id])
  end

  # Finds the +ContactFormField+ object corresponding to the passed +contact_form_field_id+ parameter.
  def find_contact_form_field
    @contact_form_field = @contact_form.contact_form_fields.find(params[:id])
  end

  def set_field_types
    @field_types = [
      [ I18n.t('contact_form_fields.textfield'), 'textfield' ],
      [ I18n.t('contact_form_fields.textarea'), 'textarea' ],
      [ I18n.t('contact_form_fields.dropdown'), 'dropdown' ]
    ]
  end
end
