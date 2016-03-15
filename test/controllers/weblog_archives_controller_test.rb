require File.expand_path('../../test_helper.rb', __FILE__)

class WeblogArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should show weblog archive' do
    get :show, id: weblog_archives(:devcms_weblog_archive).id
    assert_response :success
    assert assigns(:weblog_archive)
    assert_equal nodes(:devcms_weblog_archive_node), assigns(:node)
  end
end
