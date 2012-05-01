require File.expand_path('../../test_helper.rb', __FILE__)

class NodesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @root_section_node = nodes(:root_section_node)    
    @root_section_node.content.set_frontpage!(@root_section_node)
  end

  def test_should_get_changes_for_self_and_children
     get :changes, :format => 'atom', :id => sections(:root_section).node.id
     assert_response :success
     assert assigns(:nodes).size > 1
  end
  
  def test_should_get_changes_for_self_if_changed_feed_toggle_is_true
     assert sections(:economie_section).node.update_attribute(:has_changed_feed, true)
     
     get :changes, :format => 'atom', :id => sections(:economie_section).node.id
     assert_response :success
  end

  def test_should_get_changes_for_self_if_changed_feed_toggle_is_true
     pages(:help_page).node.update_attribute(:has_changed_feed, true)
     get :changes, :format => 'atom', :id => pages(:help_page).node.id
     assert assigns(:nodes).size == 1
  end

  def test_should_not_get_changes_for_self_if_changed_feed_toggle_is_false
     get :changes, :format => 'atom', :id => pages(:help_page).node.id
     assert_response :not_found
  end  
  
end
