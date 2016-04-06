require File.expand_path('../../../test_helper.rb', __FILE__)

# Functional tests for the +Admin::WeblogArchivesController+.
class Admin::WeblogArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    login_as :sjoerd
  end

  test 'should show weblog archive' do
    get :show, id: weblog_archives(:devcms_weblog_archive).id

    assert_response :success
    assert assigns(:weblog_archive)
    assert_equal weblog_archives(:devcms_weblog_archive).node, assigns(:node)
  end

  test 'should get index' do
    get :index, node: nodes(:devcms_weblog_archive_node).id

    assert_response :success
    assert assigns(:weblog_archive_node)
  end

  test 'should get index for offset' do
    get :index, super_node: nodes(:devcms_weblog_archive_node).id, offset: WeblogArchive::DEFAULT_OFFSET

    assert_response :success
    assert assigns(:weblog_archive_node)
    assert assigns(:offset)
  end

  test 'should get json index' do
    get :index, node: nodes(:devcms_weblog_archive_node).id, format: 'json'

    assert_response :success
    assert assigns(:weblog_archive_node)
  end

  test 'should get json index for active node' do
    get :index, node: nodes(:devcms_weblog_archive_node).id, active_node_id: weblogs(:henk_weblog).node.id, format: 'json'

    assert_response :success
    assert assigns(:weblog_archive_node)
    assert_equal true, assigns(:archive_includes_active_node)
  end

  test 'should get json index for active weblog post node' do
    get :index, node: nodes(:devcms_weblog_archive_node).id, active_node_id: weblog_posts(:henk_weblog_post_one).node.id, format: 'json'

    assert_response :success
    assert assigns(:weblog_archive_node)
    assert_equal true, assigns(:archive_includes_active_node)
  end

  test 'should get json index for invalid active node' do
    get :index, node: nodes(:devcms_weblog_archive_node).id, active_node_id: nodes(:root_section_node).id, format: 'json'

    assert_response :success
    assert assigns(:weblog_archive_node)
    assert_equal false, assigns(:archive_includes_active_node)
  end

  test 'should get json index for offset' do
    get :index, super_node: nodes(:devcms_weblog_archive_node).id, offset: WeblogArchive::DEFAULT_OFFSET, format: 'json'

    assert_response :success
    assert assigns(:weblog_archive_node)
    assert assigns(:offset)
  end

  test 'should get new' do
    get :new, parent_node_id: nodes(:root_section_node).id

    assert_response :success
    assert assigns(:weblog_archive)
  end

  test 'should get new with params' do
    get :new, parent_node_id: nodes(:root_section_node).id, weblog_archive: { title: 'foo' }

    assert_response :success
    assert assigns(:weblog_archive)
    assert_equal 'foo', assigns(:weblog_archive).title
  end

  test 'should create weblog archive' do
    assert_difference('WeblogArchive.count') do
      create_weblog_archive
    end

    assert_response :success
    refute assigns(:weblog_archive).new_record?, assigns(:weblog_archive).errors.full_messages.join('; ')
  end

  test 'should get valid preview for create' do
    assert_no_difference('WeblogArchive.count') do
      create_weblog_archive({ title: 'foobar' }, commit_type: 'preview')
    end

    assert_response :success
    assert assigns(:weblog_archive).new_record?
    assert_equal 'foobar', assigns(:weblog_archive).title
    assert_template 'create_preview'
  end

  test 'should not get invalid preview for create' do
    assert_no_difference('WeblogArchive.count') do
      create_weblog_archive({ title: nil }, commit_type: 'preview')
    end

    assert_response :unprocessable_entity
    assert assigns(:weblog_archive).new_record?
    assert assigns(:weblog_archive).errors[:title].any?
    assert_template 'new'
  end

  test 'should require title' do
    assert_no_difference('WeblogArchive.count') do
      create_weblog_archive(title: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:weblog_archive).new_record?
    assert assigns(:weblog_archive).errors[:title].any?
  end

  test 'should get edit' do
    get :edit, id: weblog_archives(:devcms_weblog_archive).id

    assert_response :success
    assert assigns(:weblog_archive)
  end

  test 'should get edit with params' do
    get :edit, id: weblog_archives(:devcms_weblog_archive).id, weblog_archive: { title: 'foo' }

    assert_response :success
    assert assigns(:weblog_archive)
    assert_equal 'foo', assigns(:weblog_archive).title
  end

  test 'should update weblog archive' do
    put :update, id: weblog_archives(:devcms_weblog_archive).id, weblog_archive: { title: 'updated title', description: 'updated_body' }

    assert_response :success
    assert_equal 'updated title', assigns(:weblog_archive).title
  end

  test 'should get valid preview for update' do
    weblog_archive = weblog_archives(:devcms_weblog_archive)
    old_title = weblog_archive.title
    put :update, id: weblog_archive, weblog_archive: { title: 'updated title', description: 'updated_body' }, commit_type: 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:weblog_archive).title
    assert_equal old_title, weblog_archive.reload.title
    assert_template 'update_preview'
  end

  test 'should not get invalid preview for update' do
    weblog_archive = weblog_archives(:devcms_weblog_archive)
    old_title = weblog_archive.title
    put :update, id: weblog_archive, weblog_archive: { title: nil, description: 'updated_body' }, commit_type: 'preview'

    assert_response :unprocessable_entity
    assert assigns(:weblog_archive).errors[:title].any?
    assert_equal old_title, weblog_archive.reload.title
    assert_template 'edit'
  end

  test 'should not update weblog archive' do
    put :update, id: weblog_archives(:devcms_weblog_archive).id, weblog_archive: { title: nil }

    assert_response :unprocessable_entity
    assert assigns(:weblog_archive).errors[:title].any?
  end

  protected

  def create_weblog_archive(attributes = {}, options = {})
    post :create, {
      parent_node_id: nodes(:root_section_node).id,
      weblog_archive: {
        title: 'Some exciting title',
        description: 'Some exciting description.'
      }.merge(attributes)
    }.merge(options)
  end
end
