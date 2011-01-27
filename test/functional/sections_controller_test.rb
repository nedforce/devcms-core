require File.dirname(__FILE__) + '/../test_helper'

class SectionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_section
    get :show, :id => sections(:root_section).id
    assert_response :success
    assert_equal [], nodes(:root_section_node).accessible_children.reject{|n| %w( Image Attachment SearchPage ).include?(n.content_type)} - assigns(:children).map(&:node)
    assert_equal nodes(:root_section_node), assigns(:node)
  end
  
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
  
  def test_should_render_404_if_hidden_for_user
    get :show, :id => sections(:hidden_section).id
    assert_response :not_found
  end
  
  def test_should_get_changes_for_self_and_children
     get :changes, :format => 'atom', :id => sections(:root_section).id
     assert assigns(:nodes).size > 1
  end
  
  def test_should_get_changes_for_self_if_changed_feed_toggle_is_true
     assert sections(:economie_section).node.update_attribute(:has_changed_feed, true)
     get :changes, :format => 'atom', :id => sections(:economie_section).id
     assert assigns(:nodes).size == 1
  end
  
end
