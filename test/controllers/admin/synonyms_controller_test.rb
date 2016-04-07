require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::SynonymsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root = nodes(:root_section_node)

    login_as :sjoerd
  end

  test 'should get index' do
    get :index, node_id: @root.id

    assert_response :success
  end

  test 'should create synonym' do
    assert_difference 'Synonym.count' do
      create_synonym
    end

    assert_response :success
    refute assigns(:synonym).new_record?, assigns(:synonym).errors.full_messages.join('; ')
  end

  test 'should destroy synonym' do
    assert_difference('Synonym.count', -1) do
      delete :destroy, node_id: @root.id, id: synonyms(:afval_vuilnis).id, format: 'json'
    end

    assert_response :success
  end

  test 'should require original' do
    assert_no_difference('Synonym.count') do
      create_synonym(original: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:synonym).new_record?
  end

  test 'should require name' do
    assert_no_difference('Synonym.count') do
      create_synonym(name: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:synonym).new_record?
  end

  test 'should require weight' do
    assert_no_difference('Synonym.count') do
      create_synonym(weight: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:synonym).new_record?
  end

  protected

  def create_synonym(options = {})
    post :create, node_id: @root.id, synonym: {
      original: 'werthers',
      name: 'echte',
      weight: '0.25'
    }.merge(options)
  end
end
