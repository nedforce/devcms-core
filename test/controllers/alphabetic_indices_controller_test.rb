require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +AlphabeticIndicesController+.
class AlphabeticIndicesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should show alphabetic index' do
    get :show, id: alphabetic_indices(:root_alphabetic_index)

    assert_response :success
    assert assigns(:alphabetic_index)
    assert assigns(:items)
    assert_equal nodes(:root_alphabetic_index_node), assigns(:node)
  end

  test 'should show alphabetic index by letter' do
    get :letter, id: alphabetic_indices(:root_alphabetic_index), letter: 'A'

    assert_response :success
    assert assigns(:alphabetic_index)
    assert assigns(:items)
    assert assigns(:letter)
    assert_equal nodes(:root_alphabetic_index_node), assigns(:node)
  end
end
