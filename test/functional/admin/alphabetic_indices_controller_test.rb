require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AlphabeticIndicesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @alphabetic_index = alphabetic_indices(:root_alphabetic_index)
  end

  def test_should_get_show
    login_as :sjoerd

    get :show, :id => @alphabetic_index
    assert_response :success
    assert assigns(:alphabetic_index)
  end

  def test_should_render_404_if_not_found
    login_as :sjoerd

    get :show, :id => -1
    assert_response :not_found
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
      assert !assigns(:alphabetic_index).new_record?, :message => assigns(:alphabetic_index).errors.full_messages.join('; ')
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('AlphabeticIndex.count') do
      create_alphabetic_index({:title => nil})
    end

    assert_response :success
    assert assigns(:alphabetic_index).new_record?
    assert assigns(:alphabetic_index).errors.on(:title)
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
    assert_response :success
    assert assigns(:alphabetic_index).errors.on(:title)
  end

  def test_should_require_roles
    assert_user_can_access  :arthur,       [ :new, :create ], { :parent_node_id => nodes(:root_section_node) }
    assert_user_cant_access :final_editor, [ :new, :create ], { :parent_node_id => nodes(:economie_section_node) }
    assert_user_cant_access :editor,       [ :new, :create ], { :parent_node_id => nodes(:root_section_node) }

    assert_user_can_access  :arthur,       [ :update, :edit ], { :id => @alphabetic_index }
    assert_user_cant_access :final_editor, [ :update, :edit ], { :id => @alphabetic_index }
    assert_user_cant_access :editor,       [ :update, :edit ], { :id => @alphabetic_index }
  end

protected

  def create_alphabetic_index(attributes = {}, options = {})
    post :create, {:parent_node_id => nodes(:root_section_node).id, :alphabetic_index => { :title => 'new title' }.merge(attributes)}.merge(options)
  end
end
