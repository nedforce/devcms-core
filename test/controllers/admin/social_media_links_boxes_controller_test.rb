require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::SocialMediaLinksBoxesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @social_media_links_box = social_media_links_boxes(:test_social_media_links_box)
  end

  test 'should get show' do
    login_as :sjoerd

    get :show, id: @social_media_links_box
    assert_response :success
    assert assigns(:social_media_links_box)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, parent_node_id: nodes(:root_section_node).id
    assert_response :success
    assert assigns(:social_media_links_box)
  end

  test 'should get new with params' do
    login_as :sjoerd

    get :new, parent_node_id: nodes(:root_section_node).id, social_media_links_box: { title: 'foo' }
    assert_response :success
    assert assigns(:social_media_links_box)
    assert_equal 'foo', assigns(:social_media_links_box).title
  end

  test 'should create social media links box' do
    login_as :sjoerd

    assert_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box
      assert_response :success
      refute assigns(:social_media_links_box).new_record?, assigns(:social_media_links_box).errors.full_messages.join('; ')
    end
  end

  test 'should get valid preview for create' do
    login_as :sjoerd

    assert_no_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box({ title: 'foobar' }, { commit_type: 'preview' })
      assert_response :success
      assert assigns(:social_media_links_box).new_record?
      assert_equal 'foobar', assigns(:social_media_links_box).title
      assert_template 'create_preview'
    end
  end

  test 'should not get invalid preview for create' do
    login_as :sjoerd

    assert_no_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box({ title: nil }, { commit_type: 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:social_media_links_box).new_record?
      assert assigns(:social_media_links_box).errors[:title].any?
      assert_template 'new'
    end
  end

  test 'should not create social media links box' do
    login_as :sjoerd

    assert_no_difference('SocialMediaLinksBox.count') do
      create_social_media_links_box(title: nil)
    end
    assert_response :unprocessable_entity
    assert assigns(:social_media_links_box).new_record?
    assert assigns(:social_media_links_box).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, id: @social_media_links_box.id
    assert_response :success
    assert assigns(:social_media_links_box)
  end

  test 'should get edit with params' do
    login_as :sjoerd

    get :edit, id: @social_media_links_box.id, social_media_links_box: { title: 'foo' }
    assert_response :success
    assert assigns(:social_media_links_box)
    assert_equal 'foo', assigns(:social_media_links_box).title
  end

  test 'should update social media links box' do
    login_as :sjoerd

    put :update, id: @social_media_links_box.id, social_media_links_box: { title: 'updated title', twitter_url: 'https://www.twitter.com/nedforce' }

    assert_response :success
    assert_equal 'updated title', assigns(:social_media_links_box).title
  end

  test 'should get valid preview for update' do
    login_as :sjoerd

    smlb = @social_media_links_box
    old_title = smlb.title
    put :update, id: smlb.id, social_media_links_box: { title: 'updated title', twitter_url: 'https://www.twitter.com/nedforce' }, commit_type: 'preview'
    assert_response :success
    assert_equal 'updated title', assigns(:social_media_links_box).title
    assert_equal old_title, smlb.reload.title
    assert_template 'update_preview'
  end

  test 'should not get invalid preview for update' do
    login_as :sjoerd

    smlb = @social_media_links_box
    old_title = smlb.title
    put :update, id: smlb.id, social_media_links_box: { title: nil, twitter_url: 'https://www.twitter.com/nedforce' }, commit_type: 'preview'
    assert_response :unprocessable_entity
    assert assigns(:social_media_links_box).errors[:title].any?
    assert_equal old_title, smlb.reload.title
    assert_template 'edit'
  end

  test 'should not update social media links box' do
    login_as :sjoerd

    put :update, id: @social_media_links_box.id, social_media_links_box: { title: nil }
    assert_response :unprocessable_entity
    assert assigns(:social_media_links_box).errors[:title].any?
  end

  protected

  def create_social_media_links_box(attributes = {}, options = {})
    post :create, {
      parent_node_id: nodes(:root_section_node).id,
      social_media_links_box: {
        title: 'new title',
        twitter_url:  'https://www.twitter.com',
        facebook_url: 'https://www.facebook.com',
        linkedin_url: 'https://www.linkedin.com',
        youtube_url:  'https://www.youtube.com',
        flickr_url:   'https://www.flickr.com'
      }.merge(attributes) }.merge(options)
  end
end
