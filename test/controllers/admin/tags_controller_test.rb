require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::TagsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    Node.root.update_attributes tag_list: 'tag1, tag2, tag3'
  end

  test 'should get index' do
    login_as :sjoerd
    get :index

    assert_response :success
  end

  test 'should update setting' do
    login_as :sjoerd
    put :update, id: ActsAsTaggableOn::Tag.last.id, tags: { name: 'new tag' }

    assert_response :success
  end

  test 'should destroy tag' do
    login_as :sjoerd

    assert_difference 'ActsAsTaggableOn::Tag.count', -1 do
      delete :destroy, id: ActsAsTaggableOn::Tag.last.id, format: 'json'
    end

    assert_response :success
  end

  test 'should not destroy tag' do
    login_as :jan

    assert_no_difference 'ActsAsTaggableOn::Tag.count' do
      delete :destroy, id: ActsAsTaggableOn::Tag.last.id, format: 'json'
    end
  end
end
