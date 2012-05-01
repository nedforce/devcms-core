require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::ContentCopiesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @content_copy = content_copies(:test_image_copy)
  end
  
  def test_should_show_content_copy
    login_as :arthur
    
    get :show, :id => @content_copy
    assert assigns(:content_copy)
    assert_response :success
    assert_equal nodes(:test_image_copy_node), assigns(:node)
  end
 
  def test_should_get_previous
    @content_copy.save :user => User.find_by_login('editor')
    
    login_as :sjoerd

    get :previous, :id => @content_copy
    assert_response :success
    assert assigns(:content_copy)
  end
  
  def test_should_create_content_copy
    login_as :arthur

    assert_difference('ContentCopy.count', 1) do
      create_content_copy
      
      assert_response :success
      assert !assigns(:content_copy).new_record?, assigns(:content_copy).errors.full_messages.join('; ')
      assert_equal assigns(:content_copy).node, nodes(:economie_section_node).reload.right_sibling
    end
  end
  
  def test_should_not_create_content_copy_for_non_copyable_copied_node
    login_as :arthur

    assert_no_difference('ContentCopy.count') do
      create_content_copy(:copied_node_id => nodes(:henk_weblog_post_one_node).id)
      
      assert_response :precondition_failed
    end
  end
    
  def test_should_not_create_content_copy_for_root_node
    login_as :arthur

    assert_no_difference('ContentCopy.count') do
      create_content_copy(:copied_node_id => nodes(:root_section_node).id)
      
      assert_response :precondition_failed
    end
  end

protected
  
  def create_content_copy(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :content_copy => { :copied_node_id => nodes(:economie_section_node).id }.merge(attributes), :format => 'json' }.merge(options)
  end
  
end
