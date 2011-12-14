require File.dirname(__FILE__) + '/../test_helper'

class SectionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @root_section_node = nodes(:root_section_node)
    
    @root_section_node.content.set_frontpage!(@root_section_node)
  end
  
  def test_should_show_section
    get :show, :id => sections(:root_section).id
    assert_response :success
  end
  
  def test_should_get_changes_for_self_and_children
     get :changes, :format => 'atom', :id => sections(:root_section).id
     assert_response :success
     assert assigns(:nodes).size > 1
  end
  
  def test_should_get_changes_for_self_if_changed_feed_toggle_is_true
     assert sections(:economie_section).node.update_attribute(:has_changed_feed, true)
     
     get :changes, :format => 'atom', :id => sections(:economie_section).id
     assert_response :success
  end
  
end
