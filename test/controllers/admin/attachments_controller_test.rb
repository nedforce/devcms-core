require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::AttachmentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    AttachmentUploader.any_instance.stubs(:path).returns(File.join(File.dirname(__FILE__), '../../fixtures/files/snippet.css.txt'))
    @attachment = attachments(:besluit_attachment)
  end

  test 'should get show' do
    login_as :sjoerd
    get :show, id: @attachment

    assert assigns(:attachment)
    assert_response :success
    assert_equal @attachment.node, assigns(:node)
  end

  test 'should get previous' do
    @attachment.title = 'foo'
    @attachment.save! user: User.find_by_login('editor')

    login_as :sjoerd
    get :previous, id: @attachment

    assert_response :success
    assert assigns(:attachment)
  end

  test 'should get new' do
    login_as :sjoerd
    get :new, parent_node_id: nodes(:about_page_node).id

    assert_response :success
    assert assigns(:attachment)
  end

  test 'should create attachment' do
    login_as :sjoerd

    assert_difference('Attachment.count', 1) do
      create_attachment
    end

    assert_response :success
    assert 'test.jpg', assigns(:attachment).filename
    refute assigns(:attachment).new_record?, assigns(:attachment).errors.full_messages.join('; ')
  end

  test 'should not create attachment' do
    login_as :sjoerd

    assert_no_difference('Attachment.count') do
      create_attachment(title: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:attachment).errors[:title].any?
  end

  test 'should allow custom filename' do
    login_as :sjoerd

    filename = 'Test bestand.jpg'
    assert_difference('Attachment.count', 1) do
      create_attachment(filename: filename)
      assert filename, assigns(:attachment).filename
    end
  end

  test 'should get edit' do
    login_as :sjoerd
    get :edit, id: attachments(:besluit_attachment).id

    assert_response :success
    assert assigns(:attachment)
  end

  test 'should get redirect for preview' do
    login_as :sjoerd
    besluit = attachments(:besluit_attachment)
    get :preview, id: besluit.id

    assert_response :redirect
  end

  test 'should get preview' do
    login_as :sjoerd
    besluit = attachments(:besluit_attachment)
    get :preview, id: besluit.id, basename: besluit.basename, baseformat: besluit.extension

    assert assigns(:attachment)
    assert_response :success
  end

  test 'should update image' do
    login_as :sjoerd
    put :update, id: attachments(:besluit_attachment).id, attachment: { title: 'updated title' }

    assert_response :success
    assert_equal 'updated title', assigns(:attachment).title
    assert_equal attachments(:besluit_attachment).content_type, assigns(:attachment).content_type
  end

  test 'should not update image' do
    login_as :sjoerd
    put :update, id: attachments(:besluit_attachment).id, attachment: { title: nil }

    assert_response :unprocessable_entity
    assert assigns(:attachment).errors[:title].any?
  end

  protected

  def create_attachment(attributes = {}, options = {})
    post :create, {
      parent_node_id: nodes(:about_page_node).id,
      attachment: {
        title: 'An Image',
        file: fixture_file_upload('files/test.jpg', 'image/jpeg', true)
      }.merge(attributes)
    }.merge(options)
  end
end
