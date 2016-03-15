require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +ImagesController+.
class ImagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @full_version_stub = stub(path: File.join(File.dirname(__FILE__), '../fixtures/files/test.jpg'))
  end

  test 'should show image' do
    ImageUploader.any_instance.expects(:full).returns(@full_version_stub)

    get :show, id: images(:test_image).id
    assert_response :success
    assert assigns :image
  end

  test 'should show full image' do
    ImageUploader.any_instance.expects(:full).returns(@full_version_stub)

    get :full, id: images(:test_image).id, format: 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', response.headers['Content-Type']
    assert_equal 'max-age=86400, public', response.headers['Cache-Control']
  end

  test 'should redirect' do
    get :full, id: images(:test_image).id
    assert_redirected_to format: 'jpg'
  end

  test 'should not redirect to private for hidden' do
    login_as :arthur
    get :full, format: 'jpg', id: images(:hidden_image).id
    assert_response :not_found
    # assert_redirected_to action: 'private_full', id: images(:hidden_image).id, format: 'jpg'
  end

  test 'should show thumbnail' do
    ImageUploader.any_instance.expects(:path).returns(File.join(File.dirname(__FILE__), '../fixtures/files/test.jpg'))

    get :thumbnail, id: images(:test_image).id, format: 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', response.headers['Content-Type']
    assert_equal  'max-age=86400, public', response.headers['Cache-Control']
  end

  test 'should show sidebox image' do
    ImageUploader.any_instance.expects(:path).returns(File.join(File.dirname(__FILE__), '../fixtures/files/test.jpg'))

    get :thumbnail, id: images(:test_image).id, format: 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', response.headers['Content-Type']
    assert_equal  'max-age=86400, public', response.headers['Cache-Control']
  end
end
