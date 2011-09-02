require File.dirname(__FILE__) + '/../../test_helper'

class Admin::SynonymsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root = nodes(:root_section_node)
  end

  def test_should_get_index
    login_as :sjoerd
    get :index, :node_id => @root.id
    assert_response :success
  end

  def test_should_create_synonym
    login_as :sjoerd

    assert_difference 'Synonym.count' do
      create_synonym
      assert_response :success
      assert !assigns(:synonym).new_record?, :message => assigns(:synonym).errors.full_messages.join('; ')
    end
  end

  def test_should_destroy_synonym
    login_as :sjoerd

    assert_difference('Synonym.count', -1) do
      delete :destroy, :node_id => @root.id, :id => synonyms(:afval_vuilnis).id, :format => 'json'
      assert_response :success
    end
  end

  def test_should_require_original
    login_as :sjoerd

    assert_no_difference('Synonym.count') do
      create_synonym(:original => nil)
    end
    assert_response :unprocessable_entity
    assert assigns(:synonym).new_record?
  end

  def test_should_require_name
    login_as :sjoerd

    assert_no_difference('Synonym.count') do
      create_synonym(:name => nil)
    end
    assert_response :unprocessable_entity
    assert assigns(:synonym).new_record?
  end

  def test_should_require_weight
    login_as :sjoerd

    assert_no_difference('Synonym.count') do
      create_synonym(:weight => nil)
    end
    assert_response :unprocessable_entity
    assert assigns(:synonym).new_record?
  end

  protected

  def create_synonym(options = {})
    post :create, :node_id => @root.id, :synonym => { :original => 'werthers', :name => 'echte', :weight => '0.25' }.merge(options)
  end
end
