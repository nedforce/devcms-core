require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::AlphabeticIndicesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @alphabetic_index = alphabetic_indices(:root_alphabetic_index)
  end

  def test_should_get_show
    login_as :sjoerd

    get :show, :id => @alphabetic_index.id
    assert_response :success
    assert assigns(:alphabetic_index)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:alphabetic_index)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :alphabetic_index => { :title => 'foo' }
    assert_response :success
    assert assigns(:alphabetic_index)
    assert_equal 'foo', assigns(:alphabetic_index).title
  end

  def test_should_create_alphabetic_index
    login_as :sjoerd

    assert_difference('AlphabeticIndex.count') do
      create_alphabetic_index
      assert_response :success
      refute assigns(:alphabetic_index).new_record?, assigns(:alphabetic_index).errors.full_messages.join('; ')
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('AlphabeticIndex.count') do
      create_alphabetic_index({ :title => nil })
    end

    assert_response :unprocessable_entity
    assert assigns(:alphabetic_index).new_record?
    assert assigns(:alphabetic_index).errors[:title].any?
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => alphabetic_indices(:subsection_alphabetic_index).id
    assert_response :success
    assert assigns(:alphabetic_index)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => alphabetic_indices(:subsection_alphabetic_index).id, :alphabetic_index => { :title => 'foo' }
    assert_response :success
    assert assigns(:alphabetic_index)
    assert_equal 'foo', assigns(:alphabetic_index).title
  end

  def test_should_update_alphabetic_index
    login_as :sjoerd

    put :update, :id => alphabetic_indices(:subsection_alphabetic_index).id, :alphabetic_index => { :title => 'updated title' }

    assert_response :success
    assert_equal 'updated title', assigns(:alphabetic_index).title
  end

  def test_should_not_update_alphabetic_index
    login_as :sjoerd

    put :update, :id => alphabetic_indices(:subsection_alphabetic_index).id, :alphabetic_index => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:alphabetic_index).errors[:title].any?
  end

protected

  def create_alphabetic_index(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :alphabetic_index => { :title => 'new title' }.merge(attributes) }.merge(options)
  end
end
