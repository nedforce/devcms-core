# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Faq+ objects.
class Admin::FaqsController < Admin::AdminController
  # The +create+ action needs the parent +Node+ object to link the new +Faq+
  # content node to.
  prepend_before_filter :find_parent_node, only: [:new, :create]

  # The +show+, +edit+ and +update+ actions need a +Faq+ object to act upon.
  before_filter :find_faq, only: [:show, :edit, :update, :previous]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, only: [:create, :update]

  before_filter :set_commit_type, only: [:create, :update]

  layout false

  require_role %w(admin final_editor editor)

  # * GET /faqs/:id
  # * GET /faqs/:id.xml
  def show
    respond_to do |format|
      format.html { render partial: 'show', locals: { record: @faq }, layout: 'admin/admin_show' }
      format.xml  { render xml: @faq }
    end
  end

  # * GET /admin/faq/:id/previous
  # * GET /admin/faq/:id/previous.xml
  def previous
    @faq = @faq.previous_version
    show
  end

  # * GET /admin/faqs/new
  def new
    @faq = Faq.new(params[:faq])

    respond_to do |format|
      format.html { render template: 'admin/shared/new', locals: { record: @faq } }
    end
  end

  # * GET /admin/faqs/:id/edit
  def edit
    @faq.attributes = params[:faq]

    respond_to do |format|
      format.html { render template: 'admin/shared/edit', locals: { record: @faq } }
    end
  end

  # * POST /admin/faqs
  # * POST /admin/faqs.xml
  def create
    @faq = Faq.new(params[:faq])
    @faq.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @faq.valid?
        format.html { render template: 'admin/shared/create_preview', locals: { record: @faq }, layout: 'admin/admin_preview' }
        format.xml  { render xml: @faq, status: :created, location: @faq }
      elsif @commit_type == 'save' && @faq.save(user: current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { head :ok }
      else
        format.html { render template: 'admin/shared/new', locals: { record: @faq }, status: :unprocessable_entity }
        format.xml  { render xml: @faq.errors, status: :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/faqs/:id
  # * PUT /admin/faqs/:id.xml
  def update
    @faq.attributes = params[:faq]

    respond_to do |format|
      if @commit_type == 'preview' && @faq.valid?
        format.html do
          find_images_and_attachments
          render template: 'admin/shared/update_preview', locals: { record: @faq }, layout: 'admin/admin_preview'
        end
        format.xml  { render xml: @faq, status: :created, location: @faq }
      elsif @commit_type == 'save' && @faq.save(user: current_user, approval_required: @for_approval)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render template: 'admin/shared/edit', locals: { record: @faq }, status: :unprocessable_entity }
        format.xml  { render xml: @faq.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  # Finds the +Faq+ object corresponding to the passed in +id+ parameter.
  def find_faq
    @faq = Faq.find(params[:id]).current_version
  end
end
