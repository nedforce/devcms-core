require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::TagsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    Node.root.update_attributes :tag_list => 'tag1, tag2, tag3'
  end

  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
  end
  
  def test_should_update_setting
    login_as :sjoerd
    put :update, :id => ActsAsTaggableOn::Tag.last.id, :tags => { :name => 'new tag' }
    assert_response :success    
  end

end
