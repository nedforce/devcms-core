require File.expand_path('../../test_helper.rb', __FILE__)

class AttachmentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    AttachmentUploader.any_instance.expects(:path).twice().returns(File.join(File.dirname(__FILE__), '../fixtures/files/snippet.css.txt'))
  end

  def test_should_get_download_for_public_attachment
    @besluit_attachment = attachments(:besluit_attachment)
    get :show, :id => @besluit_attachment.id, :basename => @besluit_attachment.basename, :format => @besluit_attachment.extension
    assert_response :success
    assert_equal @besluit_attachment.content_type, response.headers['Content-Type']
    assert_equal "attachment; filename=\"#{@besluit_attachment.filename}\"", response.headers['Content-Disposition']
    assert_equal 'max-age=86400, public', response.headers['Cache-Control']
  end

  def test_should_get_download_without_extension
    @no_extension_attachment = attachments(:no_extension_attachment)
    get :show, :id => @no_extension_attachment.id, :basename => @no_extension_attachment.basename, :format => @no_extension_attachment.extension
    assert_response :success
    assert_equal @no_extension_attachment.content_type, response.headers['Content-Type']
    assert_equal "attachment; filename=\"#{@no_extension_attachment.filename}\"", response.headers['Content-Disposition']
    assert_equal 'max-age=86400, public', response.headers['Cache-Control']
  end
end
