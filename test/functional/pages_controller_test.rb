require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +PagesController+.
class PagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should show page' do
    get :show, id: pages(:help_page).id

    assert_response :success
    assert assigns(:page)
    assert_equal nodes(:help_page_node), assigns(:node)
  end

  test 'should increment hits on show' do
    page = pages(:help_page)
    old_hits = page.node.hits
    get :show, id: page

    assert_equal old_hits + 1, page.node.reload.hits
  end

  test 'should have lang attributes if locale is set' do
    page = pages(:english_page)
    get :show, id: page.id

    assert_response :success
    assert assigns(:page)
    assert_tag :h1, attributes: { lang: page.node.locale }
  end

  test 'should render 404 if hidden for user' do
    get :show, id: pages(:hidden_page).id

    assert_response :not_found
  end
end
