require File.dirname(__FILE__) + '/../test_helper'

class AttachmentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_redirect
    @besluit_attachment = attachments(:besluit_attachment)
    get :show, :id => @besluit_attachment.id
    assert_redirected_to :controller => 'attachments', :action => 'show', :id => @besluit_attachment.id, :basename => @besluit_attachment.basename, :format => @besluit_attachment.extension
  end
  
  def test_should_render_404_for_private_attachment
    @hidden_attachment = attachments(:hidden_attachment)
    get :show, :id => @hidden_attachment.id
    assert_response :not_found
  end
  
  def test_should_get_404
    @besluit_attachment = attachments(:besluit_attachment)
    get :show, :id => @besluit_attachment.id, :basename => 'incorrect'
    assert_response :not_found
  end
  
  def test_should_get_download_for_public_attachment
    @besluit_attachment = attachments(:besluit_attachment)
    get :show, :id => @besluit_attachment.id, :basename => @besluit_attachment.basename, :format => @besluit_attachment.extension
    assert_response :success
    assert_equal @besluit_attachment.content_type, @response.headers['Content-Type']
    assert_equal @besluit_attachment.size.to_s, @response.headers['Content-Length']
    assert_equal "attachment; filename=\"#{@besluit_attachment.filename}\"", @response.headers['Content-Disposition']
    assert_equal 'public', @response.headers['Cache-Control']
  end
  
  def test_should_get_download_for_private_attachment_for_admin
    login_as :sjoerd
    
    @hidden_attachment = attachments(:hidden_attachment)
    get :private, :id => @hidden_attachment.id, :basename => @hidden_attachment.basename, :format => @hidden_attachment.extension
    assert_response :success
    assert_equal @hidden_attachment.content_type, @response.headers['Content-Type']
    assert_equal @hidden_attachment.size.to_s, @response.headers['Content-Length']
    assert_equal "attachment; filename=\"#{@hidden_attachment.filename}\"", @response.headers['Content-Disposition']
    assert_equal 'private', @response.headers['Cache-Control']
  end
  
  def test_should_not_get_download_for_private_attachment_for_non_user
    @hidden_attachment = attachments(:hidden_attachment)
    get :private, :id => @hidden_attachment.id, :basename => @hidden_attachment.basename, :format => @hidden_attachment.extension
    assert_response :not_found
  end
  
  def test_should_get_download_without_extension
    @no_extension_attachment = attachments(:no_extension_attachment)
    get :show, :id => @no_extension_attachment.id, :basename => @no_extension_attachment.basename, :format => @no_extension_attachment.extension
    assert_response :success
    assert_equal @no_extension_attachment.content_type, @response.headers['Content-Type']
    assert_equal @no_extension_attachment.size.to_s, @response.headers['Content-Length']
    assert_equal "attachment; filename=\"#{@no_extension_attachment.filename}\"", @response.headers['Content-Disposition']
    assert_equal 'public', @response.headers['Cache-Control']
  end
end
