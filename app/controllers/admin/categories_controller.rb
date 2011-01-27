class Admin::CategoriesController < Admin::AdminController

  skip_before_filter :set_actions
  skip_before_filter :find_node    

  require_role 'admin', :except => [ :category_options, :synonyms, :add_to_favorites, :remove_from_favorites ]

  require_role ['admin', 'final_editor', 'editor'], :only => [ :category_options, :synonyms, :add_to_favorites, :remove_from_favorites ], :any_node => true

  layout false

  # * GET /admin/categories
  # * GET /admin/categories.json
  def index
    @active_page = :categories
    respond_to do |format|
      format.html { render :layout => 'admin' }
      format.json do
        @categories = Category.find(:all)
        categories = @categories.collect do |category|
          {
            :id         => category.id,
            :table_name => (category.is_root_category? ? "#{I18n.t('categories.root_category')}" : category.name),
            :name       => category.name,
            :group      => (category.parent.nil? ? category.name : category.parent.name),
            :is_root    => category.parent.nil?,
            :created_at => category.created_at,
            :updated_at => category.updated_at
          }
        end
        render :json => { :categories => categories, :total_count => @categories.size }.to_json, :status => :ok
      end
    end
  end

  def create
    @category = Category.new(params[:category])
    respond_to do |format|
      if @category.save
        format.json { render :json => { :success => 'true' } }
      else
        format.json { render :json => @category.errors.full_messages.join(' '), :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/categories/1.json
  def update
    @category = Category.find(params[:id])
    params[:category].delete(:parent_id) if params[:category][:parent_id].blank?

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.json { render :json => { :success => 'true' } }
      else
        format.json { render :json => @category.errors.full_messages.join(' '), :status => :unprocessable_entity }
      end
    end
  end

  # Destroys a +Category+.
  # * DELETE /admin/categories/1.json
  def destroy
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.destroy
        format.json { render :json => { :success => 'true' } }
      else
        format.json { render :json => @category.errors.full_messages.join(' '), :status => :unprocessable_entity }
      end
    end
  end

  def root_categories
    @root_categories = Category.root_categories.all(:order => :name)
    respond_to do |format|
      format.json do
        categories = @root_categories.collect do |category|
          {
            :id   => category.id,
            :name => category.name
          }
        end
        render :json => { :categories => categories, :total_count => categories.size }.to_json , :status => :ok
      end
    end
  end

  def categories
    @categories = Category.all
    respond_to do |format|
      format.json do
        categories = @categories.collect do |category|
          {
            :id    => category.id,
            :label => category.to_label
          }
        end
        render :json => { :categories => categories.sort_by { |c| c[:label] }, :total_count => categories.size }.to_json , :status => :ok
      end
    end
  end

  def category_options
    root_category = Category.root_categories.find(params[:id])
    render :partial => 'category_options', :locals => { :categories => root_category.children, :default_id => root_category.id, :selected_id => root_category.id }
  end

  def synonyms
    category = Category.find(params[:id])
    render :partial => 'synonyms', :locals => { :category => category }
  end

  def add_to_favorites
    current_user.add_category_to_favorites(Category.find(params[:id]))
    render :partial => 'favorites'
  end

  def remove_from_favorites
    current_user.remove_category_from_favorites(Category.find(params[:id]))
    render :partial => 'favorites'
  end
end
