require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::NewsViewersControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @news_viewer = create_news_viewer
  end

  def test_should_show_news_viewer
    login_as :sjoerd

    get :show, :id => @news_viewer.id
    assert_response :success
    assert assigns(:news_viewer)
    assert assigns(:news_items)
    assert assigns(:news_items_for_table)
    assert assigns(:latest_news_items)
    assert_equal @news_viewer.node, assigns(:node)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:news_viewer)
  end

  test 'should get new with params' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :news_viewer => { :title => 'foo' }
    assert_response :success
    assert assigns(:news_viewer)
    assert_equal 'foo', assigns(:news_viewer).title
  end

  def test_should_create_news_viewer
    login_as :sjoerd

    assert_difference('NewsViewer.count') do
      create_news_viewer
      assert_response :success
      refute assigns(:news_viewer).new_record?, assigns(:news_viewer).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsViewer.count') do
      create_news_viewer({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:news_viewer).new_record?
      assert_equal 'foobar', assigns(:news_viewer).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsViewer.count') do
      create_news_viewer({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:news_viewer).new_record?
      assert assigns(:news_viewer).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('NewsViewer.count') do
      create_news_viewer({ :title => nil })
    end

    assert_response :unprocessable_entity
    assert assigns(:news_viewer).new_record?
    assert assigns(:news_viewer).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, :id => @news_viewer
    assert_response :success
    assert assigns(:news_viewer)
  end

  test 'should get edit items' do
    login_as :sjoerd

    get :edit_items, id: @news_viewer
    assert_response :success
    assert assigns(:news_archives)
  end

  test 'should get edit items without archived' do
    login_as :sjoerd
    # Two fixtures, set one as archived
    news_archives(:other_news).update_attributes(archived: true)

    get :edit_items, id: @news_viewer
    assert_response :success
    assert assigns(:news_archives)
    assert_equal 1, assigns(:news_archives).count
  end

  test 'should update news viewer' do
    login_as :sjoerd

    put :update, :id => @news_viewer, :news_viewer => { :title => 'updated title', :description => 'updated description' }

    assert_response :success
    assert_equal 'updated title', assigns(:news_viewer).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    old_title = @news_viewer.title
    put :update, :id => @news_viewer, :news_viewer => { :title => 'updated title', :description => 'updated description' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:news_viewer).title
    assert_equal old_title, @news_viewer.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    old_title = @news_viewer.title
    put :update, :id => @news_viewer, :news_viewer => { :title => nil, :description => 'updated description' }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:news_viewer).errors[:title].any?
    assert_equal old_title, @news_viewer.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_news_viewer
    login_as :sjoerd

    put :update, :id => @news_viewer.id, :news_viewer => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:news_viewer).errors[:title].any?
  end

protected

  def create_news_viewer(attributes = {}, options = {})
    login_as :sjoerd
    post :create, { :parent_node_id => nodes(:economie_section_node).id, :commit_type => 'save', :news_viewer => { :title => 'NewsViewer', :description => 'A News Viewer' }.merge(attributes) }.merge(options)
    assigns(:news_viewer)
  end
end
