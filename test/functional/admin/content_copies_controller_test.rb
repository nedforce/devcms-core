require File.dirname(__FILE__) + '/../../test_helper'

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
    @content_copy.create_approved_version
    login_as :sjoerd

    get :previous, :id => @content_copy
    assert_response :success
    assert assigns(:content_copy)
  end
    
  def test_should_render_404_if_not_found
    login_as :arthur
        
    get :show, :id => -1
    assert_response :not_found
  end  
  
  def test_should_create_content_copy
    login_as :arthur

    assert_difference('ContentCopy.count', 1) do
      create_content_copy
      
      assert_response :success
      assert !assigns(:content_copy).new_record?, :message => assigns(:content_copy).errors.full_messages.join('; ')
      assert_equal assigns(:content_copy).node, nodes(:economie_section_node).reload.right_sibling
    end
  end
  
  def test_should_not_create_content_copy_for_non_copyable_copied_node
    login_as :arthur

    assert_no_difference('ContentCopy.count') do
      create_content_copy(:copied_node => nodes(:henk_weblog_post_one_node))
      
      assert_response :precondition_failed
    end
  end
    
  def test_should_not_create_content_copy_for_root_node
    login_as :arthur

    assert_no_difference('ContentCopy.count') do
      create_content_copy(:copied_node => nodes(:root_section_node))
      
      assert_response :precondition_failed
    end
  end
    
  def test_should_require_roles
    assert_user_can_access :arthur, :create, { :parent_node_id => nodes(:root_section_node).id }
    assert_user_can_access :final_editor, :create, { :parent_node_id => nodes(:economie_section_node).id }
    assert_user_can_access :editor, :create, { :parent_node_id => nodes(:editor_section_node).id }
    assert_user_cant_access :final_editor, :create, { :parent_node_id => nodes(:editor_section_node).id }
    assert_user_cant_access :editor, :create, { :parent_node_id => nodes(:economie_section_node).id }
    assert_user_can_access :arthur, :create, { :parent_node_id => nodes(:editor_section_node).id }
    assert_user_can_access :arthur, :create, { :parent_node_id => nodes(:economie_section_node).id }
  end

protected
  
  def create_content_copy(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :content_copy => { :copied_node => nodes(:economie_section_node) }.merge(attributes), :format => 'json' }.merge(options)
  end
  
end
