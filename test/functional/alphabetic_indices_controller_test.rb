require File.dirname(__FILE__) + '/../test_helper'

class AlphabeticIndicesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_alphabetic_index
    get :show, :id => alphabetic_indices(:root_alphabetic_index)
    assert_response :success
    assert assigns(:alphabetic_index)
    assert assigns(:items)
    assert_equal nodes(:root_alphabetic_index_node), assigns(:node)
  end

  def test_should_show_alphabetic_index_by_letter
    get :letter, :id => alphabetic_indices(:root_alphabetic_index), :letter => 'A'
    assert_response :success
    assert assigns(:alphabetic_index)
    assert assigns(:items)
    assert assigns(:letter)
    assert_equal nodes(:root_alphabetic_index_node), assigns(:node)
  end
end
