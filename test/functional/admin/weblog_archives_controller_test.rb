require File.dirname(__FILE__) + '/../../test_helper'

class Admin::WeblogArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_weblog_archive
    login_as :sjoerd

    get :show, :id => weblog_archives(:devcms_weblog_archive).id
    assert_response :success
    assert assigns(:weblog_archive)
    assert_equal weblog_archives(:devcms_weblog_archive).node, assigns(:node)
  end

  def test_should_get_index
    login_as :sjoerd

    get :index, :node => nodes(:devcms_weblog_archive_node).id
    assert_response :success
    assert assigns(:weblog_archive_node)
  end

  def test_should_get_index_for_offset
    login_as :sjoerd

    get :index, :super_node => nodes(:devcms_weblog_archive_node).id, :offset => WeblogArchive::DEFAULT_OFFSET
    assert_response :success
    assert assigns(:weblog_archive_node)
    assert assigns(:offset)
  end

  def test_should_get_json_index
    login_as :sjoerd

    get :index, :node => nodes(:devcms_weblog_archive_node).id, :format => 'json'
    assert_response :success
    assert assigns(:weblog_archive_node)
  end

  def test_should_get_json_index_for_active_node
    login_as :sjoerd

    get :index, :node => nodes(:devcms_weblog_archive_node).id, :active_node_id => weblogs(:henk_weblog).node.id, :format => 'json'
    assert_response :success
    assert assigns(:weblog_archive_node)
    assert_equal true, assigns(:archive_includes_active_node)
  end

  def test_should_get_json_index_for_active_weblog_post_node
    login_as :sjoerd

    get :index, :node => nodes(:devcms_weblog_archive_node).id, :active_node_id => weblog_posts(:henk_weblog_post_one).node.id, :format => 'json'
    assert_response :success
    assert assigns(:weblog_archive_node)
    assert_equal true, assigns(:archive_includes_active_node)
  end

  def test_should_get_json_index_for_invalid_active_node
    login_as :sjoerd

    get :index, :node => nodes(:devcms_weblog_archive_node).id, :active_node_id =>  nodes(:root_section_node).id, :format => 'json'
    assert_response :success
    assert assigns(:weblog_archive_node)
    assert_equal false, assigns(:archive_includes_active_node)
  end

  def test_should_get_json_index_for_offset
    login_as :sjoerd

    get :index, :super_node => nodes(:devcms_weblog_archive_node).id, :offset => WeblogArchive::DEFAULT_OFFSET, :format => 'json'
    assert_response :success
    assert assigns(:weblog_archive_node)
    assert assigns(:offset)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:weblog_archive)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :weblog_archive => { :title => 'foo' }
    assert_response :success
    assert assigns(:weblog_archive)
    assert_equal 'foo', assigns(:weblog_archive).title
  end

  def test_should_create_weblog_archive
    login_as :sjoerd

    assert_difference('WeblogArchive.count') do
      create_weblog_archive
      assert_response :success
      assert !assigns(:weblog_archive).new_record?, :message => assigns(:weblog_archive).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('WeblogArchive.count') do
      create_weblog_archive({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:weblog_archive).new_record?
      assert_equal 'foobar', assigns(:weblog_archive).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('WeblogArchive.count') do
      create_weblog_archive({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:weblog_archive).new_record?
      assert assigns(:weblog_archive).errors.on(:title)
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('WeblogArchive.count') do
      create_weblog_archive(:title => nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:weblog_archive).new_record?
    assert assigns(:weblog_archive).errors.on(:title)
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => weblog_archives(:devcms_weblog_archive).id
    assert_response :success
    assert assigns(:weblog_archive)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => weblog_archives(:devcms_weblog_archive).id, :weblog_archive => { :title => 'foo' }
    assert_response :success
    assert assigns(:weblog_archive)
    assert_equal 'foo', assigns(:weblog_archive).title
  end

  def test_should_update_weblog_archive
    login_as :sjoerd

    put :update, :id => weblog_archives(:devcms_weblog_archive).id, :weblog_archive => { :title => 'updated title', :description => 'updated_body'}

    assert_response :success
    assert_equal 'updated title', assigns(:weblog_archive).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    weblog_archive = weblog_archives(:devcms_weblog_archive)
    old_title = weblog_archive.title
    put :update, :id => weblog_archive, :weblog_archive => { :title => 'updated title', :description => 'updated_body'}, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:weblog_archive).title
    assert_equal old_title, weblog_archive.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    weblog_archive = weblog_archives(:devcms_weblog_archive)
    old_title = weblog_archive.title
    put :update, :id => weblog_archive, :weblog_archive => { :title => nil, :description => 'updated_body'}, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:weblog_archive).errors.on(:title)
    assert_equal old_title, weblog_archive.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_weblog_archive
    login_as :sjoerd

    put :update, :id => weblog_archives(:devcms_weblog_archive).id, :weblog_archive => {:title => nil}
    assert_response :unprocessable_entity
    assert assigns(:weblog_archive).errors.on(:title)
  end

protected

  def create_weblog_archive(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :weblog_archive => { :title => "Some exciting title.", :description => "Some exciting description." }.merge(attributes) }.merge(options)
  end

end

