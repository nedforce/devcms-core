require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::WeblogPostsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_weblog_post
    login_as :sjoerd    
    
    get :show, :parent_node_id => nodes(:henk_weblog_node).id, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :success
    assert assigns(:weblog_post)
    assert_equal weblog_posts(:henk_weblog_post_one).node, assigns(:node)
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :success
    assert assigns(:weblog_post)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => weblog_posts(:henk_weblog_post_one).id, :weblog_post => { :title => 'foo' }
    assert_response :success
    assert assigns(:weblog_post)
    assert_equal 'foo', assigns(:weblog_post).title
  end

  def test_should_update_weblog_post
    login_as :sjoerd
    
    put :update, :id => weblog_posts(:henk_weblog_post_one).id, :weblog_post => { :title => 'updated title', :body => 'updated body' }
    
    assert_response :success
    assert_equal 'updated title', assigns(:weblog_post).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    weblog_post = weblog_posts(:henk_weblog_post_one)
    old_title = weblog_post.title
    put :update, :id => weblog_post, :weblog_post => { :title => 'updated title', :body => 'updated body' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:weblog_post).title
    assert_equal old_title, weblog_post.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    weblog_post = weblog_posts(:henk_weblog_post_one)
    old_title = weblog_post.title
    put :update, :id => weblog_post, :weblog_post => { :title => nil, :body => 'updated body' }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:weblog_post).errors[:title].any?
    assert_equal old_title, weblog_post.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_weblog_post_with_invalid_title
    login_as :sjoerd
    
    put :update, :id => weblog_posts(:henk_weblog_post_one), :weblog_post => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:weblog_post).errors[:title].any?
  end

  def test_should_set_publication_start_date_on_update
    login_as :sjoerd

    date = 1.year.from_now

    put :update, :id => weblog_posts(:henk_weblog_post_one),
                 :weblog_post => { :publication_start_date_day => date.strftime("%d-%m-%Y"), :publication_start_date_time => date.strftime("%H:%M") }

    assert_response :success
    assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:weblog_post).publication_start_date
  end

end
