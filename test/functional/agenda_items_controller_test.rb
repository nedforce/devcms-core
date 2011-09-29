require File.dirname(__FILE__) + '/../test_helper'

class AgendaItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_agenda_item
    get :show, :id => agenda_items(:agenda_item_one).id
    assert_response :success
    assert assigns(:agenda_item)
    assert_equal nodes(:agenda_item_one_node), assigns(:node)
  end
 
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
end
