require File.dirname(__FILE__) + '/../test_helper'

# Tests content_node functionality on the pages controller.
class ContentNodesTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  tests PagesController

  def test_should_not_show_hidden_page
    get :show, :id => pages(:hidden_page).id
    assert_response :not_found
  end

  def test_should_not_show_page_in_hidden_section
    get :show, :id => pages(:nested_page).id
    assert_response :not_found
  end

  def test_should_require_roles
    assert_user_can_access :normal_user, :show, {:id => pages(:about_page).id}
    assert_user_can_access :arthur, :show, {:id => pages(:hidden_page).id}
    assert_user_can_access :reader, :show, {:id => pages(:hidden_page).id}
    assert_user_cant_access :normal_user, :show, {:id => pages(:hidden_page).id}
  end

  def test_should_show_hidden_children_to_authorized_user
    login_as :reader
    get :show, :id => pages(:not_hidden_page).id
    assert_response :success
    assert !assigns(:image_content_nodes).empty?
    assert !assigns(:attachment_content_nodes).empty?
  end

  def test_should_not_show_hidden_children_to_unauthorized_user
    get :show, :id => pages(:not_hidden_page).id
    assert_response :success
    assert assigns(:image_content_nodes).empty?
    assert assigns(:attachment_content_nodes).empty?
  end

  def test_should_get_changes_for_self_if_changed_feed_toggle_is_true
     pages(:help_page).node.update_attribute(:has_changed_feed, true)
     get :changes, :format => 'atom', :id => pages(:help_page).id
     assert assigns(:nodes).size == 1
  end

  def test_should_get_changes_for_self_if_changed_feed_toggle_is_false
     get :changes, :format => 'atom', :id => pages(:help_page).id
     assert_response 404
  end

  def test_should_not_include_header_images_in_content_children
    images(:hidden_image).send(:update_attributes, :is_for_header => true)
    login_as :reader
    get :show, :id => pages(:not_hidden_page).id
    assert_response :success
    assert assigns(:image_content_nodes).empty?
  end
  
  def test_should_handle_invalid_ids
    get :show, :id => -1
    assert_response :not_found
  end
end

