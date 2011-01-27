require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CategoriesControllerTest < ActionController::TestCase

  def setup
    @category = create_category
  end

  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
  end

  def test_should_get_root_categories
    login_as :sjoerd

    create_category(:name => 'Child', :parent => create_category(:name => 'Parent') )

    get :root_categories, :format => 'json'
    assert_response :success
    assert assigns(:root_categories)
    assigns(:root_categories).map{|c| assert_nil c.parent }
  end

  def test_should_get_categories
    login_as :sjoerd

    create_category(:name => 'Child', :parent => create_category(:name => 'Parent') )

    get :categories, :format => 'json'
    assert_response :success
  end

  def test_should_create_category
    login_as :sjoerd

    assert_difference 'Category.count' do
      post :create, :category => { :name => 'Test category' }
      assert_response :success
      assert !assigns(:category).new_record?, :message => assigns(:category).errors.full_messages.join('; ')
    end
  end

  def test_should_update_category
    login_as :sjoerd

    assert_no_difference 'Category.count' do
      post :update, :id => @category.id, :category => { :name => 'Test category' }
      assert_response :success
      assert !assigns(:category).new_record?, :message => assigns(:category).errors.full_messages.join('; ')
    end
  end

  def test_should_not_update_category_parent
    login_as :sjoerd

    parent = create_category(:name => 'Parent')
    @category.update_attribute(:parent, parent)

    assert @category.parent
    post :update, :id => @category.id, :category => { :name => 'Test category', :parent_id => '' }

    assert_response :success
    assert_equal 'Test category', assigns(:category).name
    assert_equal parent, assigns(:category).parent
  end

  def test_should_destroy_category
    login_as :sjoerd
    assert_difference('Category.count', -1) do
      delete :destroy, :id => @category.id, :format => 'json'
      assert_response :success
    end
  end

  def test_should_require_name
    login_as :sjoerd

    assert_no_difference('Category.count') do
      post :create, :category => { :name => nil }
    end
    assert_response :internal_server_error
    assert assigns(:category).new_record?
  end

  def test_should_get_category_options
    login_as :sjoerd

    root_category = create_category(:name => 'Parent')
    create_category(:name => 'Child', :parent => root_category)

    get :category_options, :id => root_category.to_param
    assert_response :success
  end

  def test_should_get_synonyms
    login_as :sjoerd

    category = create_category(:name => 'Parent', :synonyms => 'Foo, Bar, Baz')

    get :synonyms, :id => category.to_param
    assert_response :success
  end

  def test_should_add_favorite_category
    login_as :sjoerd

    user = users(:sjoerd)

    category = create_category(:name => 'Parent', :synonyms => 'Foo, Bar, Baz')

    assert !user.categories.include?(category)

    put :add_to_favorites, :id => category
    assert_response :success

    assert user.categories.include?(category)
  end

  def test_should_remove_favorite_category
    login_as :sjoerd

    user = users(:sjoerd)

    category = create_category(:name => 'Parent', :synonyms => 'Foo, Bar, Baz')

    user.categories << category

    assert user.categories.include?(category)

    put :remove_from_favorites, :id => category
    assert_response :success

    assert !user.categories.include?(category)
  end

  def test_should_require_roles
    assert_user_can_access  :arthur,       :index
    assert_user_can_access  :arthur,       :create,                                        { :category => { :name => 'Another category' }}
    assert_user_can_access  :arthur,       :update,              { :id => Category.first.id, :category => { :name => 'Another category' }}
    assert_user_can_access  :arthur,       :destroy,               :id => Category.first.id
    assert_user_cant_access :editor,       [ :create, :update, :index, :destroy ]
    assert_user_cant_access :final_editor, [ :create, :update, :index, :destroy ]
    assert_user_can_access  :arthur,       :category_options,      :id => Category.first.id
    assert_user_can_access  :arthur,       :synonyms,              :id => Category.first.id
    assert_user_can_access  :arthur,       :add_to_favorites,      :id => Category.first.id
    assert_user_can_access  :arthur,       :remove_from_favorites, :id => Category.first.id
    assert_user_can_access  :editor,       :category_options,      :id => Category.first.id
    assert_user_can_access  :editor,       :synonyms,              :id => Category.first.id
    assert_user_can_access  :editor,       :add_to_favorites,      :id => Category.first.id
    assert_user_can_access  :editor,       :remove_from_favorites, :id => Category.first.id
    assert_user_can_access  :final_editor, :category_options,      :id => Category.first.id
    assert_user_can_access  :final_editor, :synonyms,              :id => Category.first.id
    assert_user_can_access  :final_editor, :add_to_favorites,      :id => Category.first.id
    assert_user_can_access  :final_editor, :remove_from_favorites, :id => Category.first.id
  end

  protected

  def create_category(options = {})
    Category.create({ :name => 'New category' }.merge(options))
  end
end
