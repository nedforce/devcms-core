require File.expand_path('../../test_helper.rb', __FILE__)

class AgendaItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should show agenda item' do
    get :show, id: agenda_items(:agenda_item_one).id

    assert_response :success
    assert assigns(:agenda_item)
    assert_equal nodes(:agenda_item_one_node), assigns(:node)
  end
end
