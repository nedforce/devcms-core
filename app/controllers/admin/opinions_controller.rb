# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to administering +Opinion+ objects.
class Admin::OpinionsController < Admin::AdminController
  # The +show+, +new+, +create+, +edit+ and +update+ actions need the
  # parent +Node+ object to link the new +Opinion+ content node to.
  prepend_before_filter :find_parent_node,     only: [:new, :create]

  # The +show+, +edit+ and +update+ actions need a +Opinion+ object to act upon.
  before_filter :find_opinion,                 only: [:show, :edit, :update]

  before_filter :set_commit_type,              only: [:create, :update]

  layout false

  require_role %w(admin final_editor editor)

  # GET /admin/opinions/:id
  # GET /admin/opinions/:id.xml
  def show
    respond_to do |format|
      format.html { render partial: 'show', layout: 'admin/admin_show' }
      format.xml  { render xml: @opinion.to_xml }
    end
  end

  # * GET /admin/opinions/new
  def new
    @opinion = Opinion.new(permitted_attributes)
    @votes = []
    set_default_values
  end
  
  # * GET /admin/opinions/:id/edit
  def edit
    @opinion.attributes = permitted_attributes
  end

  # * POST /admin/opinions
  # * POST /admin/opinions.xml
  def create
    puts "=============================================================="
    puts "permitted: " + permitted_attributes.to_s
    puts "=============================================================="
    @opinion                  = Opinion.new(permitted_attributes)
    puts "1.1 " + @opinion.entry_1_1.to_s
    @opinion.title          ||= params[:opinion][:title]
    @opinion.title          ||= t('opinions.default_title')
    @opinion.parent           = @parent_node
    @votes = []
    
    respond_to do |format|
      if @commit_type == 'preview' && @opinion.valid?
        format.html { render template: 'admin/shared/create_preview', locals: { record: @opinion }, layout: 'admin/admin_preview' }
        format.xml  { render xml: @opinion, status: :created, location: @opinion }
      elsif @commit_type == 'save' && @opinion.save(user: current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render xml: @opinion, status: :created, location: @opinion }
      else
        format.html { render action: :new }
        format.xml  { render xml: @opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/opinions/:id
  # * PUT /admin/opinions/:id.xml
  def update
    @opinion.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @opinion.valid?
        format.html { render template: 'admin/shared/update_preview', locals: { record: @opinion }, layout: 'admin/admin_preview' }
        format.xml  { render xml: @opinion, status: :created, location: @opinion }
      elsif @commit_type == 'save' && @opinion.save(user: current_user)
        format.html do
          @refresh = true
          render 'admin/shared/update'
        end
        format.xml  { head :ok }
      else
        format.html { render action: :edit }
        format.xml  { render xml: @opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def permitted_attributes
    params.fetch(:opinion, {}).permit!
  end

  # Finds the +Opinion+ object corresponding to the passed in +id+ parameter.
  def find_opinion
    @opinion = Opinion.find(params[:id])
    @votes = OpinionEntry.where(opinion: @opinion)
  end

  def set_default_values
    @opinion.title = t('opinions.default_title')
    @opinion.subtitle = t('opinions.default_subtitle')
    @opinion.parent = @parent_node
    @opinion.entry_1_1 = t('opinions.option_good_1')
    @opinion.entry_1_2 = t('opinions.option_good_2')
    @opinion.entry_1_3 = t('opinions.option_good_3')
    @opinion.entry_1_4 = t('opinions.option_good_4')
    @opinion.entry_2_1 = t('opinions.option_neutral_1')
    @opinion.entry_2_2 = t('opinions.option_neutral_2')
    @opinion.entry_2_3 = t('opinions.option_neutral_3')
    @opinion.entry_2_4 = t('opinions.option_neutral_4')
    @opinion.entry_3_1 = t('opinions.option_bad_1')
    @opinion.entry_3_2 = t('opinions.option_bad_2')
    @opinion.entry_3_3 = t('opinions.option_bad_3')
    @opinion.entry_3_4 = t('opinions.option_bad_4')
  end

end
