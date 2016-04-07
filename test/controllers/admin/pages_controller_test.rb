require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::PagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @page = pages(:help_page)
  end

  test 'should get show' do
    login_as :sjoerd

    get :show, id: @page
    assert_response :success
    assert assigns(:page)
  end

  test 'should not increment hits on show' do
    page = pages(:help_page)
    old_hits = page.node.hits
    get :show, id: page

    assert_equal old_hits, page.node.reload.hits
  end

  test 'should get previous' do
    @page.save user: User.find_by_login('editor')
    
    login_as :sjoerd

    get :previous, id: @page

    assert_response :success
    assert assigns(:page)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, parent_node_id: nodes(:root_section_node).id

    assert_response :success
    assert assigns(:page)
  end

  test 'should get new with params' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, page: { title: 'foo' }

    assert_response :success
    assert assigns(:page)
    assert_equal 'foo', assigns(:page).title
  end

  test 'should create page' do
    login_as :sjoerd

    assert_difference('Page.count') do
      create_page
      assert_response :success
      refute assigns(:page).new_record?, assigns(:page).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Page.count') do
      create_page({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:page).new_record?
      assert_equal 'foobar', assigns(:page).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Page.count') do
      create_page({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:page).new_record?
      assert assigns(:page).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('Page.count') do
      create_page({ :title => nil })
    end
    assert_response :unprocessable_entity
    assert assigns(:page).new_record?
    assert assigns(:page).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, :id => pages(:help_page).id
    assert_response :success
    assert assigns(:page)
  end

  test 'should get edit with params' do
    login_as :sjoerd

    get :edit, :id => pages(:help_page).id, :page => { :title => 'foo' }
    assert_response :success
    assert assigns(:page)
    assert_equal 'foo', assigns(:page).title
  end

  def test_should_update_page
    login_as :sjoerd

    put :update, :id => pages(:help_page).id, :page => { :title => 'updated title', :body => 'updated_body' }

    assert_response :success
    assert_equal 'updated title', assigns(:page).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    page      = pages(:help_page)
    old_title = page.title
    put :update, :id => page.id, :page => { :title => 'updated title', :body => 'updated_body' }, :commit_type => 'preview'
    assert_response :success
    assert_equal 'updated title', assigns(:page).title
    assert_equal old_title, page.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    page      = pages(:help_page)
    old_title = page.title
    put :update, :id => page.id, :page => { :title => nil, :body => 'updated_body' }, :commit_type => 'preview'
    assert_response :unprocessable_entity
    assert assigns(:page).errors[:title].any?
    assert_equal old_title, page.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_page
    login_as :sjoerd

    put :update, :id => pages(:help_page).id, :page => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:page).errors[:title].any?
  end

  def test_should_set_publication_start_date_on_create
    login_as :sjoerd

    assert_difference('Page.count') do
      date = 1.year.from_now
      create_page :publication_start_date => date
      assert_response :success
      assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:page).publication_start_date
    end
  end

  def test_should_set_publication_start_date_on_update
    login_as :sjoerd

    date = 1.year.from_now

    put :update, :id => @page,
                 :page => { :publication_start_date_day => date.strftime("%d-%m-%Y"), :publication_start_date_time => date.strftime("%H:%M") }

    assert_response :success
    assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:page).publication_start_date
  end

protected

  def create_page(attributes = {}, options = {})
    publication_start_date = attributes.delete(:publication_start_date) || Time.now
    post :create, { :parent_node_id => nodes(:root_section_node).id, :page => { :title => 'new title', :preamble => 'new preamble', :body => 'Lorem ipsum', :publication_start_date_day => publication_start_date.strftime("%d-%m-%Y"), :publication_start_date_time => publication_start_date.strftime("%H:%M") }.merge(attributes) }.merge(options)
  end
end
