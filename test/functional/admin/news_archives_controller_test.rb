require File.dirname(__FILE__) + '/../../test_helper'

class Admin::NewsArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_news_archive
    login_as :sjoerd    

    get :show, :id => news_archives(:devcms_news).id
    assert_response :success
    assert assigns(:news_archive)
    assert_equal news_archives(:devcms_news).node, assigns(:node)
  end  

  def test_should_get_index
    login_as :sjoerd

    get :index, :node => nodes(:devcms_news_node).id
    assert_response :success
    assert assigns(:news_archive_node)
  end

  def test_should_get_index_for_year
    login_as :sjoerd

    get :index, :super_node => nodes(:devcms_news_node).id, :year => '2008'
    assert_response :success
    assert assigns(:news_archive_node)
    assert assigns(:year)
  end

  def test_should_get_index_for_year_and_month
    login_as :sjoerd

    get :index, :super_node => nodes(:devcms_news_node).id, :year => '2008', :month => '1'
    assert_response :success
    assert assigns(:news_archive_node)
    assert assigns(:year)
    assert assigns(:month)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:news_archive)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :news_archive => { :title => 'foo' }
    assert_response :success
    assert assigns(:news_archive)
    assert_equal 'foo', assigns(:news_archive).title
  end

  def test_should_create_news_archive
    login_as :sjoerd

    assert_difference('NewsArchive.count') do
      create_news_archive
      assert_response :success
      assert !assigns(:news_archive).new_record?, :message => assigns(:news_archive).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsArchive.count') do
      create_news_archive({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:news_archive).new_record?
      assert_equal 'foobar', assigns(:news_archive).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsArchive.count') do
      create_news_archive({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:news_archive).new_record?
      assert assigns(:news_archive).errors.on(:title)
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('NewsArchive.count') do
      create_news_archive({ :title => nil })
    end

    assert_response :unprocessable_entity
    assert assigns(:news_archive).new_record?
    assert assigns(:news_archive).errors.on(:title)
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => news_archives(:devcms_news).id
    assert_response :success
    assert assigns(:news_archive)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => news_archives(:devcms_news).id, :news_archive => { :title => 'foo' }
    assert_response :success
    assert assigns(:news_archive)
    assert_equal 'foo', assigns(:news_archive).title
  end

  def test_should_update_news_archive
    login_as :sjoerd

    put :update, :id => news_archives(:devcms_news).id, :news_archive => { :title => 'updated title', :description => 'updated description' }

    assert_response :success
    assert_equal 'updated title', assigns(:news_archive).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    news_archive = news_archives(:devcms_news)
    old_title    = news_archive.title
    put :update, :id => news_archive, :news_archive => { :title => 'updated title', :description => 'updated description' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:news_archive).title
    assert_equal old_title, news_archive.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    news_archive = news_archives(:devcms_news)
    old_title    = news_archive.title
    put :update, :id => news_archive, :news_archive => { :title => nil, :description => 'updated description' }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:news_archive).errors.on(:title)
    assert_equal old_title, news_archive.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_news_archive
    login_as :sjoerd

    put :update, :id => news_archives(:devcms_news).id, :news_archive => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:news_archive).errors.on(:title)
  end

protected

  def create_news_archive(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :news_archive => { :title => 'Good news, everyone!', :description => "I'm sending you all on a highly controversial mission." }.merge(attributes) }.merge(options)
  end
end
