require File.dirname(__FILE__) + '/../test_helper'

class WeblogPostsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_weblog_post
    get :show, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :success
    assert assigns(:weblog_post)
    assert_equal nodes(:henk_weblog_post_one_node), assigns(:node)
  end

  def test_should_show_weblog_post_atom
    get :show, :id => weblog_posts(:henk_weblog_post_one).id, :format => 'atom'
    assert_response :success
  end

  def test_should_render_404_for_invalid_weblog_archive
    login_as :henk
    get :edit, :weblog_archive_id => nil, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :not_found
  end

  def test_should_render_404_for_invalid_weblog
    login_as :henk
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => nil, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :not_found
  end

  def test_should_render_404_for_invalid_weblog_post
    login_as :henk
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => nil
    assert_response :not_found
  end

  def test_should_get_new_for_owner_of_weblog
    login_as :henk
    get :new, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id
    assert assigns(:weblog_post)
    assert_response :success
  end

  def test_should_get_new_for_admin
    login_as :sjoerd
    get :new, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id
    assert assigns(:weblog_post)
    assert_response :success
  end

  def test_should_not_get_new_for_non_owner_of_weblog
    login_as :gerjan
    get :new, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id
    assert_response :redirect
  end

  def test_should_not_get_new_for_non_user
    get :new, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id
    assert_response :redirect
  end

  def test_should_create_weblog_post_for_owner_of_weblog
    login_as :henk
    assert_difference('WeblogPost.count', 1) do
      create_weblog_post
      assert_response :redirect
      assert !assigns(:weblog_post).new_record?, :message => assigns(:weblog_post).errors.full_messages.join('; ')
    end
  end

  def test_should_create_weblog_post_for_admin
    login_as :sjoerd
    assert_difference('WeblogPost.count', 1) do
      create_weblog_post
      assert_response :redirect
      assert !assigns(:weblog_post).new_record?, :message => assigns(:weblog_post).errors.full_messages.join('; ')
    end
  end

  def test_should_not_create_weblog_post_with_invalid_title
    login_as :henk
    assert_no_difference('WeblogPost.count') do
      create_weblog_post(:title => nil)
      assert_response :success
      assert assigns(:weblog_post).errors.on(:title)
    end
  end

  def test_should_not_create_weblog_post_for_non_owner_of_weblog
    login_as :gerjan
    assert_no_difference('WeblogPost.count') do
      create_weblog_post
      assert_response :redirect
    end
  end

  def test_should_not_create_weblog_post_for_non_user
    assert_no_difference('WeblogPost.count') do
      create_weblog_post()
      assert_response :redirect
    end
  end

  def test_should_get_edit_for_owner_of_weblog
    login_as :henk
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :success
    assert assigns(:weblog_post)
  end

  def test_should_get_edit_for_admin
    login_as :sjoerd
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :success
    assert assigns(:weblog_post)
  end

  def test_should_not_get_edit_for_non_owner_of_weblog
    login_as :gerjan
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :redirect
  end

  def test_should_not_get_edit_for_non_user
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    assert_response :redirect
  end

  def test_should_update_weblog_post_for_owner_of_weblog
    login_as :henk
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :weblog_post => { :title => 'updated title' }
    assert_response :redirect
    assert_equal 'updated title', assigns(:weblog_post).title
  end

  def test_should_update_weblog_post_for_admin
    login_as :sjoerd
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :weblog_post => { :title => 'updated title' }
    assert_response :redirect
    assert_equal 'updated title', assigns(:weblog_post).title
  end

  def test_should_not_update_weblog_post_with_invalid_title
    login_as :henk
    old_title = weblog_posts(:henk_weblog_post_one).title
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :weblog_post => { :title => nil }
    assert_response :success
    assert assigns(:weblog_post).errors.on(:title)
    assert_equal old_title, weblog_posts(:henk_weblog_post_one).reload.title
  end

  def test_should_not_update_weblog_post_for_non_user
    old_title = weblog_posts(:henk_weblog_post_one).title
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :weblog_post => { :title => 'updated title' }
    assert_response :redirect
    assert_equal old_title, weblog_posts(:henk_weblog_post_one).reload.title
  end

  def test_should_not_update_weblog_post_for_non_owner_of_weblog
    login_as :gerjan
    old_title = weblog_posts(:henk_weblog_post_one).title
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :weblog_post => { :title => 'updated title' }
    assert_response :redirect
    assert_equal old_title, weblog_posts(:henk_weblog_post_one).reload.title
  end

  def test_should_destroy_weblog_post_for_owner_of_weblog
    login_as :henk
    assert_difference('WeblogPost.count', -1) do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    end
    assert_response :redirect
  end

  def test_should_show_confirmationon_destroy_with_get
    login_as :henk
    assert_no_difference('WeblogPost.count') do
      get :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
      assert_template 'confirm_destroy'
    end
  end

  def test_should_destroy_weblog_post_for_admin
    login_as :sjoerd
    assert_difference('WeblogPost.count', -1) do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    end
    assert_response :redirect
  end

  def test_should_not_destroy_weblog_post_for_non_owner_of_weblog
    login_as :gerjan
    assert_no_difference 'WeblogPost.count' do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    end
    assert_response :redirect
  end

  def test_should_not_destroy_weblog_post_for_non_user
    assert_no_difference 'WeblogPost.count' do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id
    end
    assert_response :redirect
  end

  def test_should_create_with_images
    login_as :henk
    image = fixture_file_upload("files/test.jpg")
    assert_difference('WeblogPost.count', 1) do
      assert_difference('Image.count', 2) do
        create_weblog_post({},{:images => { :image_0 => { :title => 'An Image', :data => image },:image_1 => { :title => 'Another Image', :data => image }}})
        assert_response :redirect
        assert !assigns(:weblog_post).new_record?, :message => assigns(:weblog_post).errors.full_messages.join('; ')
      end
    end
    images = assigns(:weblog_post).node.children
    assert_equal 2, images.size
    assert images.all? { |i| i.parent_id.equal?(assigns(:weblog_post).node.id)}
    assert images.all? { |i| !i.root?}
    assert images.all? { |i| !i.approved_content(:allow_nil => true).nil?}
  end

  def test_should_not_create_with_more_than_four_images
    login_as :henk
    image = fixture_file_upload("files/test.jpg")
    assert_difference('WeblogPost.count', 1) do
      assert_difference('Image.count', 4) do
        create_weblog_post({}, { :images => {:image_0 => { :data => image },
                    :image_1 => { :data => image },
                    :image_2 => { :data => image },
                    :image_4 => { :data => image },
                    :image_3 => { :data => image}}})

        assert_response :redirect
        assert_equal 4, assigns(:weblog_post).node.children.size
      end
    end
  end

  def test_should_add_images_on_update
    login_as :henk
    image = fixture_file_upload("files/test.jpg")
    assert_difference('Image.count', 3) do
      put :update,  :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id,
                    :weblog_id => weblogs(:henk_weblog).id,
                    :id => weblog_posts(:henk_weblog_post_one).id,
                    :images => {:image_0 => { :data => image },
                                :image_1 => { :data => image },
                                :image_2 => { :data => image },
                                :image_3 => { :data => image}}
    end
    assert_response :redirect
  end

  def test_should_remove_image_from_weblog_for_owner
    login_as :henk
    assert_difference('Image.count', -1) do
      delete :destroy_image, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :image_id => images(:henks_weblog_image).id
    end
    assert_response :redirect
  end

  def test_should_remove_image_from_weblog_for_admin
    login_as :sjoerd
    assert_difference('Image.count', -1) do
      delete :destroy_image, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :image_id => images(:henks_weblog_image).id
    end
    assert_response :redirect
  end

  def test_should_not_remove_image_from_weblog_for_non_owner
    login_as :piet
    assert_no_difference('Image.count') do
      delete :destroy_image, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :id => weblog_posts(:henk_weblog_post_one).id, :image_id => images(:henks_weblog_image).id
    end
    assert_response :redirect
  end

 protected

  def create_weblog_post(attributes = {}, options = {})
    post :create, { :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog_id => weblogs(:henk_weblog).id, :weblog_post => { :title => 'Some title.', :body => 'Some body', :publication_start_date => Time.now }.merge(attributes)}.merge(options)
  end

end
