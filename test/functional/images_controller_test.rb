require File.dirname(__FILE__) + '/../test_helper'

class ImagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_redirect
    get :full, :id => images(:test_image).id
    assert_redirected_to :format => 'jpg'
  end
  
  def test_should_redirect_to_private
    login_as :arthur
    get :full, :format => 'jpg', :id => images(:hidden_image).id
    assert_redirected_to :action => "private_full", :id => images(:hidden_image).id, :format => 'jpg'
  end

  def test_should_show_full_image
    get :full, :id => images(:test_image).id, :format => 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', @response.headers['Content-Type']
    assert_equal 'public', @response.headers['Cache-Control']
  end
  
  def test_should_show_thumbnail
    get :thumbnail, :id => images(:test_image).id, :format => 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', @response.headers['Content-Type']
    assert_equal 'public', @response.headers['Cache-Control']
  end
   
  def test_should_show_sidebox_image
    get :thumbnail, :id => images(:test_image).id, :format => 'jpg'
    assert_response :success
    assert_equal 'image/jpeg', @response.headers['Content-Type']
    assert_equal 'public', @response.headers['Cache-Control']
  end
  
  def test_should_show_image
    get :show, :id => images(:test_image).id
    assert_response :success
    assert assigns(:image)
  end
  
end