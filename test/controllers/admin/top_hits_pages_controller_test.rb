require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::TopHitsPagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @top_hits_page = top_hits_pages(:top_ten_page)
  end

  test 'should get show' do
    login_as :sjoerd

    get :show, :id => @top_hits_page
    assert_response :success
    assert assigns(:top_hits_page)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:top_hits_page)
  end

  test 'should get new with params' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :top_hits_page => { :title => 'foo' }
    assert_response :success
    assert assigns(:top_hits_page)
    assert_equal 'foo', assigns(:top_hits_page).title
  end

  def test_should_create_top_hits_page
    login_as :sjoerd

    assert_difference('TopHitsPage.count') do
      create_top_hits_page
      assert_response :success
      refute assigns(:top_hits_page).new_record?, assigns(:top_hits_page).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('TopHitsPage.count') do
      create_top_hits_page({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:top_hits_page).new_record?
      assert_equal 'foobar', assigns(:top_hits_page).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('TopHitsPage.count') do
      create_top_hits_page({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:top_hits_page).new_record?
      assert assigns(:top_hits_page).errors[:title].any?
      assert_template 'new'
    end
  end

  test 'should require title' do
    login_as :sjoerd

    assert_no_difference('TopHitsPage.count') do
      create_top_hits_page({ :title => nil })
    end

    assert_response :unprocessable_entity
    assert assigns(:top_hits_page).new_record?
    assert assigns(:top_hits_page).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, :id => top_hits_pages(:top_ten_page).id
    assert_response :success
    assert assigns(:top_hits_page)
  end

  test 'should get edit with params' do
    login_as :sjoerd

    get :edit, :id => top_hits_pages(:top_ten_page).id, :top_hits_page => { :title => 'foo' }
    assert_response :success
    assert assigns(:top_hits_page)
    assert_equal 'foo', assigns(:top_hits_page).title
  end

  def test_should_update_top_hits_page
    login_as :sjoerd

    put :update, :id => top_hits_pages(:top_ten_page).id, :top_hits_page => { :title => 'updated title' }

    assert_response :success
    assert_equal 'updated title', assigns(:top_hits_page).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    top_hits_page = top_hits_pages(:top_ten_page)
    old_title = top_hits_page.title
    put :update, :id => top_hits_page.id, :top_hits_page => { :title => 'updated title' }, :commit_type => 'preview'
    assert_response :success
    assert_equal 'updated title', assigns(:top_hits_page).title
    assert_equal old_title, top_hits_page.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    top_hits_page = top_hits_pages(:top_ten_page)
    old_title = top_hits_page.title
    put :update, :id => top_hits_page.id, :top_hits_page => { :title => nil }, :commit_type => 'preview'
    assert_response :unprocessable_entity
    assert assigns(:top_hits_page).errors[:title].any?
    assert_equal old_title, top_hits_page.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_top_hits_page
    login_as :sjoerd

    put :update, :id => top_hits_pages(:top_ten_page).id, :top_hits_page => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:top_hits_page).errors[:title].any?
  end

protected

  def create_top_hits_page(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :top_hits_page => { :title => 'new title' }.merge(attributes) }.merge(options)
  end
end
