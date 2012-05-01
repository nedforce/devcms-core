require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::NewsletterArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_newsletter_archive
    login_as :sjoerd

    get :show, :id => newsletter_archives(:devcms_newsletter_archive).id
    assert_response :success
    assert assigns(:newsletter_archive)
    assert_equal newsletter_archives(:devcms_newsletter_archive).node, assigns(:node)
  end

  def test_should_show_all_newsletter_editions_for_archive
    login_as :sjoerd

    6.times { create_newsletter_edition }
    get :show, :id => newsletter_archives(:devcms_newsletter_archive).id
    assert_response :success
    assert assigns(:newsletter_archive)
    assert_equal newsletter_archives(:devcms_newsletter_archive).node, assigns(:node)
  end

  def test_should_get_index
    login_as :sjoerd

    get :index, :node => nodes(:newsletter_archive_node).id
    assert_response :success
  end

  def test_should_get_index_for_year
    login_as :sjoerd

    get :index, :super_node => nodes(:newsletter_archive_node).id, :year => '2008'
    assert_response :success
    assert assigns(:year)
  end

  def test_should_get_index_for_year_and_month
    login_as :sjoerd

    get :index, :super_node => nodes(:newsletter_archive_node).id, :year => '2008', :month => '1'
    assert_response :success
    assert assigns(:year)
    assert assigns(:month)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:newsletter_archive)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :newsletter_archive => { :title => 'foo' }
    assert_response :success
    assert assigns(:newsletter_archive)
    assert_equal 'foo', assigns(:newsletter_archive).title
  end

  def test_should_create_newsletter_archive
    login_as :sjoerd

    assert_difference('NewsletterArchive.count') do
      create_newsletter_archive
      assert_response :success
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsletterArchive.count') do
      create_newsletter_archive({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:newsletter_archive).new_record?
      assert_equal 'foobar', assigns(:newsletter_archive).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsletterArchive.count') do
      create_newsletter_archive({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:newsletter_archive).new_record?
      assert assigns(:newsletter_archive).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('NewsletterArchive.count') do
      create_newsletter_archive({:title => nil})
    end
    assert_response :unprocessable_entity
    assert assigns(:newsletter_archive).new_record?
    assert assigns(:newsletter_archive).errors[:title].any?
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => newsletter_archives(:devcms_newsletter_archive).id
    assert_response :success
    assert assigns(:newsletter_archive)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => newsletter_archives(:devcms_newsletter_archive).id, :newsletter_archive => { :title => 'foo' }
    assert_response :success
    assert assigns(:newsletter_archive)
    assert_equal 'foo', assigns(:newsletter_archive).title
  end

  def test_should_update_newsletter_archive
    login_as :sjoerd

    put :update, :id => newsletter_archives(:devcms_newsletter_archive).id, :newsletter_archive => {:title => 'updated title', :description => 'updated_body'}

    assert_response :success
    assert_equal 'updated title', assigns(:newsletter_archive).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    newsletter_archive = newsletter_archives(:devcms_newsletter_archive)
    old_title = newsletter_archive.title
    put :update, :id => newsletter_archive, :newsletter_archive => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:newsletter_archive).title
    assert_equal old_title, newsletter_archive.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    newsletter_archive = newsletter_archives(:devcms_newsletter_archive)
    old_title = newsletter_archive.title
    put :update, :id => newsletter_archive, :newsletter_archive => { :title => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:newsletter_archive).errors[:title].any?
    assert_equal old_title, newsletter_archive.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_section
    login_as :sjoerd

    put :update, :id => newsletter_archives(:devcms_newsletter_archive).id, :newsletter_archive => {:title => nil}
    assert_response :unprocessable_entity
    assert assigns(:newsletter_archive).errors[:title].any?
  end

protected

  def create_newsletter_archive(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :newsletter_archive => { :title => "Good news, everyone!", :description => "I'm sending you all on a highly controversial mission.", :header => Settler[:newsletter_archive_header_default] }.merge(attributes) }.merge(options)
  end

  def create_newsletter_edition(options = {})
    NewsletterEdition.create({:parent => nodes(:newsletter_archive_node), :title => "Het maandelijkse nieuws!", :published => 'publishing', :body => "O o o wat is het weer een fijne maand geweest." }.merge(options))
  end

end

