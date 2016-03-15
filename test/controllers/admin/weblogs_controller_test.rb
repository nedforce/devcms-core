require File.expand_path('../../../test_helper.rb', __FILE__)

# Functional tests for the +Admin::WeblogsController+.
class Admin::WeblogsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    login_as :sjoerd
  end

  test 'should show weblog' do
    get :show, parent_node_id: nodes(:devcms_weblog_archive_node), id: weblogs(:henk_weblog).id

    assert_response :success
    assert assigns(:weblog)
    assert_equal weblogs(:henk_weblog).node, assigns(:node)
  end

  test 'should get index' do
    get :index, node: nodes(:henk_weblog_node).id

    assert_response :success
    assert assigns(:weblog_node)
  end

  test 'should get index for year' do
    get :index, super_node: nodes(:henk_weblog_node).id, year: '2008'

    assert_response :success
    assert assigns(:weblog_node)
    assert assigns(:year)
  end

  test 'should get index for year and month' do
    get :index, super_node: nodes(:henk_weblog_node).id, year: '2008', month: '1'

    assert_response :success
    assert assigns(:weblog_node)
    assert assigns(:year)
    assert assigns(:month)
  end

  test 'should get edit' do
    get :edit, id: weblogs(:henk_weblog).id

    assert_response :success
    assert assigns(:weblog)
  end

  test 'should get edit with params' do
    get :edit, id: weblogs(:henk_weblog).id, weblog: { title: 'foo' }

    assert_response :success
    assert assigns(:weblog)
    assert_equal 'foo', assigns(:weblog).title
  end

  test 'should update weblog' do
    put :update, id: weblogs(:henk_weblog).id, weblog: { title: 'updated title', description: 'updated description' }

    assert_response :success
    assert_equal 'updated title', assigns(:weblog).title
  end

  test 'should get valid preview for update' do
    weblog = weblogs(:henk_weblog)
    old_title = weblog.title
    put :update, id: weblog, weblog: { title: 'updated title', description: 'updated description' }, commit_type: 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:weblog).title
    assert_equal old_title, weblog.reload.title
    assert_template 'update_preview'
  end

  test 'should not get invalid preview for update' do
    weblog = weblogs(:henk_weblog)
    old_title = weblog.title
    put :update, id: weblog, weblog: { title: nil, description: 'updated description' }, commit_type: 'preview'

    assert_response :unprocessable_entity
    assert assigns(:weblog).errors[:title].any?
    assert_equal old_title, weblog.reload.title
    assert_template 'edit'
  end

  test 'should not update weblog' do
    put :update, id: weblogs(:henk_weblog).id, weblog: { title: nil }

    assert_response :unprocessable_entity
    assert assigns(:weblog).errors[:title].any?
  end
end
