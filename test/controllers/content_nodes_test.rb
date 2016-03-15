require File.expand_path('../../test_helper.rb', __FILE__)

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

  def test_should_not_include_header_images_in_content_children
    hidden_image = Image.find(images(:hidden_image).id)
    hidden_image.update_attributes(:is_for_header => true)
    login_as :reader
    get :show, :id => pages(:not_hidden_page).id
    assert_response :success
    assert assigns(:image_content_nodes).empty?
  end
end
