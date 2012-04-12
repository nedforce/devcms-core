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

  def test_should_not_show_hidden_children_to_authorized_user
    login_as :reader
    get :show, :id => pages(:not_hidden_page).id
    assert_response :success
    assert assigns(:image_content_nodes).empty?
    assert assigns(:attachment_nodes).empty?
  end

  def test_should_not_show_hidden_children_to_unauthorized_user
    get :show, :id => pages(:not_hidden_page).id
    assert_response :success
    assert assigns(:image_content_nodes).empty?, "Expected assigns(:image_content_nodes) to be empty, got instead: #{assigns(:image_content_nodes).pretty_inspect}"
    assert assigns(:attachment_nodes).empty?
  end

  def test_should_get_changes_for_self_if_changed_feed_toggle_is_true
     pages(:help_page).node.update_attribute(:has_changed_feed, true)
     get :changes, :format => 'atom', :id => pages(:help_page).id
     assert assigns(:nodes).size == 1
  end

  def test_should_not_get_changes_for_self_if_changed_feed_toggle_is_false
     get :changes, :format => 'atom', :id => pages(:help_page).id
     assert_response :not_found
  end

  def test_should_not_include_header_images_in_content_children
    hidden_image = Image.select_all_columns.find(images(:hidden_image).id)
    hidden_image.update_attributes(:is_for_header => true)
    login_as :reader
    get :show, :id => pages(:not_hidden_page).id
    assert_response :success
    assert assigns(:image_content_nodes).empty?
  end
end

