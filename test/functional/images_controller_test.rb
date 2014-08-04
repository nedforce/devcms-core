require File.expand_path('../../test_helper.rb', __FILE__)

class ImagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @full_version_stub = stub(:path => File.join(File.dirname(__FILE__), '../fixtures/files/test.jpg'))
  end

  def test_should_show_image
    ImageUploader.any_instance.expects(:full).returns(@full_version_stub)

    get :show, :id => images(:test_image).id
    assert_response :success
    assert assigns :image
  end

  def test_should_show_full_image
    ImageUploader.any_instance.expects(:full).returns(@full_version_stub)

    get :full, :id => images(:test_image).id, :format => 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', @response.headers['Content-Type']
    assert_equal 'public',     @response.headers['Cache-Control']
  end

  def test_should_redirect
    get :full, :id => images(:test_image).id
    assert_redirected_to :format => 'jpg'
  end

  def test_should_not_redirect_to_private_for_hidden
    login_as :arthur
    get :full, :format => 'jpg', :id => images(:hidden_image).id
    assert_response :not_found
    # assert_redirected_to :action => "private_full", :id => images(:hidden_image).id, :format => 'jpg'
  end

  def test_should_show_thumbnail
    ImageUploader.any_instance.expects(:path).returns(File.join(File.dirname(__FILE__), '../fixtures/files/test.jpg'))

    get :thumbnail, :id => images(:test_image).id, :format => 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', @response.headers['Content-Type']
    assert_equal 'public',     @response.headers['Cache-Control']
  end

  def test_should_show_sidebox_image
    ImageUploader.any_instance.expects(:path).returns(File.join(File.dirname(__FILE__), '../fixtures/files/test.jpg'))

    get :thumbnail, :id => images(:test_image).id, :format => 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', @response.headers['Content-Type']
    assert_equal 'public',     @response.headers['Cache-Control']
  end
end
