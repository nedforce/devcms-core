require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::NewsItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @news_item = news_items(:devcms_news_item)
  end

  def test_should_show_news_item
    login_as :sjoerd

    get :show, :id => @news_item
    assert assigns(:news_item)
    assert_response :success
    assert_equal @news_item.node, assigns(:node)
  end

  def test_should_get_previous
    @news_item.save :user => User.find_by_login('editor')

    login_as :sjoerd

    get :previous, :id => @news_item
    assert_response :success
    assert assigns(:news_item)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:devcms_news_node).id
    assert_response :success
    assert assigns(:news_item)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:devcms_news_node).id, :news_item => { :title => 'foo' }
    assert_response :success
    assert assigns(:news_item)
    assert_equal 'foo', assigns(:news_item).title
  end

  def test_should_create_news_item
    login_as :sjoerd

    assert_difference('NewsItem.count') do
      create_news_item
      assert_response :success
      assert !assigns(:news_item).new_record?, assigns(:news_item).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsItem.count') do
      create_news_item({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:news_item).new_record?
      assert_equal 'foobar', assigns(:news_item).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsItem.count') do
      create_news_item({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:news_item).new_record?
      assert assigns(:news_item).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('NewsItem.count') do
      create_news_item(:title => nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:news_item).new_record?
    assert assigns(:news_item).errors[:title].any?
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => news_items(:devcms_news_item).id
    assert_response :success
    assert assigns(:news_item)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => news_items(:devcms_news_item).id, :news_item => { :title => 'foo' }
    assert_response :success
    assert assigns(:news_item)
    assert_equal 'foo', assigns(:news_item).title
  end

  def test_should_update_news_item
    login_as :sjoerd

    put :update, :id => news_items(:devcms_news_item).id, :news_item => { :title => 'updated title', :body => 'updated body' }

    assert_response :success
    assert_equal 'updated title', assigns(:news_item).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    news_item = news_items(:devcms_news_item)
    old_title = news_item.title
    put :update, :id => news_item.id, :news_item => { :title => 'updated title' }, :commit_type => 'preview'
    assert_response :success
    assert_equal 'updated title', assigns(:news_item).title
    assert_equal old_title, news_item.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    news_item = news_items(:devcms_news_item)
    old_title = news_item.title
    put :update, :id => news_item.id, :news_item => { :title => nil }, :commit_type => 'preview'
    assert_response :unprocessable_entity
    assert assigns(:news_item).errors[:title].any?
    assert_equal old_title, news_item.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_news_item
    login_as :sjoerd

    put :update, :id => news_items(:devcms_news_item).id, :news_item => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:news_item).errors[:title].any?
  end

  def test_should_set_publication_start_date_on_create
    login_as :sjoerd

    assert_difference('NewsItem.count') do
      date = 1.year.from_now
      create_news_item :publication_start_date => date
      assert_response :success
      assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:news_item).publication_start_date
    end
  end

  def test_should_set_publication_start_date_on_update
    login_as :sjoerd

    date = 1.year.from_now

    put :update, :id => @news_item,
                 :news_item => { :publication_start_date_day => date.strftime("%d-%m-%Y"), :publication_start_date_time => date.strftime("%H:%M") }

    assert_response :success
    assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:news_item).publication_start_date
  end

protected

  def create_news_item(attributes = {}, options = {})
    publication_start_date = attributes.delete(:publication_start_date) || Time.now
    post :create, { :parent_node_id => nodes(:devcms_news_node).id, :news_item => { :title => 'new title', :body => 'Lorem ipsum', :publication_start_date_day => publication_start_date.strftime("%d-%m-%Y"), :publication_start_date_time => publication_start_date.strftime("%H:%M") }.merge(attributes) }.merge(options)
  end
end
