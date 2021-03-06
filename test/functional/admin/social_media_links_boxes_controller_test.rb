require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::SocialMediaLinksBoxesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @social_media_links_box = social_media_links_boxes(:test_social_media_links_box)
  end

  def test_should_get_show
    login_as :sjoerd

    get :show, id: @social_media_links_box
    assert_response :success
    assert assigns(:social_media_links_box)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, parent_node_id: nodes(:root_section_node).id
    assert_response :success
    assert assigns(:social_media_links_box)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, parent_node_id: nodes(:root_section_node).id, social_media_links_box: { title: 'foo' }
    assert_response :success
    assert assigns(:social_media_links_box)
    assert_equal 'foo', assigns(:social_media_links_box).title
  end

  def test_should_create_social_media_links_box
    login_as :sjoerd

    assert_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box
      assert_response :success
      assert !assigns(:social_media_links_box).new_record?, assigns(:social_media_links_box).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box({ title: 'foobar' }, { commit_type: 'preview' })
      assert_response :success
      assert assigns(:social_media_links_box).new_record?
      assert_equal 'foobar', assigns(:social_media_links_box).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box({ title: nil }, { commit_type: 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:social_media_links_box).new_record?
      assert assigns(:social_media_links_box).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_not_create_social_media_links_box
    login_as :sjoerd

    assert_no_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box({ title: nil })
    end
    assert_response :unprocessable_entity
    assert assigns(:social_media_links_box).new_record?
    assert assigns(:social_media_links_box).errors[:title].any?
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => @social_media_links_box.id
    assert_response :success
    assert assigns(:social_media_links_box)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, id: @social_media_links_box.id, social_media_links_box: { title: 'foo' }
    assert_response :success
    assert assigns(:social_media_links_box)
    assert_equal 'foo', assigns(:social_media_links_box).title
  end

  def test_should_update_social_media_links_box
    login_as :sjoerd

    put :update, :id => @social_media_links_box.id, :social_media_links_box => { :title => 'updated title', :twitter_url => 'http://www.twitter.com/nedforce' }

    assert_response :success
    assert_equal 'updated title', assigns(:social_media_links_box).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    smlb = @social_media_links_box
    old_title = smlb.title
    put :update, :id => smlb.id, :social_media_links_box => { :title => 'updated title', :twitter_url => 'http://www.twitter.com/nedforce' }, :commit_type => 'preview'
    assert_response :success
    assert_equal 'updated title', assigns(:social_media_links_box).title
    assert_equal old_title, smlb.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    smlb = @social_media_links_box
    old_title = smlb.title
    put :update, :id => smlb.id, :social_media_links_box => { :title => nil, :twitter_url => 'http://www.twitter.com/nedforce' }, :commit_type => 'preview'
    assert_response :unprocessable_entity
    assert assigns(:social_media_links_box).errors[:title].any?
    assert_equal old_title, smlb.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_social_media_links_box
    login_as :sjoerd

    put :update, :id => @social_media_links_box.id, :social_media_links_box => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:social_media_links_box).errors[:title].any?
  end

  protected

  def create_social_media_links_box(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id,
         :social_media_links_box => { :title => 'new title',
         :twitter_url  => 'http://www.twitter.com',  :facebook_url => 'http://www.facebook.com',
         :linkedin_url => 'http://www.linkedin.com', :youtube_url  => 'http://www.youtube.com',
         :flickr_url   => 'http://www.flickr.com' }.merge(attributes) }.merge(options)
  end
end
