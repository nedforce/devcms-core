require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::AttachmentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    AttachmentUploader.any_instance.stubs(:path).returns(File.join(File.dirname(__FILE__), '../../fixtures/files/snippet.css.txt'))
    @attachment = attachments(:besluit_attachment)
  end

  def test_should_get_show
    login_as :sjoerd
    get :show, :id => @attachment
    assert assigns(:attachment)
    assert_response :success
    assert_equal @attachment.node, assigns(:node)
  end

  def test_should_get_previous
    @attachment.title = 'foo'
    @attachment.save! :user => User.find_by_login('editor')

    login_as :sjoerd
    get :previous, :id => @attachment
    assert_response :success
    assert assigns(:attachment)
  end

  def test_should_get_new
    login_as :sjoerd
    get :new, :parent_node_id => nodes(:about_page_node).id
    assert_response :success
    assert assigns(:attachment)
  end

  def test_should_create_attachment
    login_as :sjoerd
    assert_difference('Attachment.count', 1) do
      create_attachment
      assert_response :success
      assert 'test.jpg', assigns(:attachment).filename
      refute assigns(:attachment).new_record?, assigns(:attachment).errors.full_messages.join('; ')
    end
  end

  def test_should_not_create_attachment
    login_as :sjoerd
    assert_no_difference('Attachment.count') do
      create_attachment(:title => nil)
      assert_response :unprocessable_entity
      assert assigns(:attachment).errors[:title].any?
    end
  end

  def test_should_allow_custom_filename
    login_as :sjoerd
    assert_difference('Attachment.count', 1) do
      filename = "Test bestand.jpg"
      create_attachment(:filename => filename)
      assert filename, assigns(:attachment).filename
    end
  end

  def test_should_get_edit
    login_as :sjoerd
    get :edit, :id => attachments(:besluit_attachment).id
    assert_response :success
    assert assigns(:attachment)
  end

  def test_should_get_redirect_for_preview
    login_as :sjoerd
    besluit = attachments(:besluit_attachment)
    get :preview, :id => besluit.id
    assert_response :redirect
  end

  def test_should_get_preview
    login_as :sjoerd
    besluit = attachments(:besluit_attachment)
    get :preview, :id => besluit.id, :basename => besluit.basename, :baseformat => besluit.extension
    assert assigns(:attachment)
    assert_response :success
  end

  def test_should_update_image
    login_as :sjoerd
    put :update, :id => attachments(:besluit_attachment).id, :attachment => { :title => 'updated title' }
    assert_response :success
    assert_equal 'updated title', assigns(:attachment).title
    assert_equal attachments(:besluit_attachment).content_type, assigns(:attachment).content_type
  end

  def test_should_not_update_image
    login_as :sjoerd
    put :update, :id => attachments(:besluit_attachment).id, :attachment => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:attachment).errors[:title].any?
  end

  protected

  def create_attachment(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:about_page_node).id, :attachment => { :title => 'An Image', :file => fixture_file_upload('files/test.jpg', 'image/jpeg', true) }.merge(attributes) }.merge(options)
  end
end
