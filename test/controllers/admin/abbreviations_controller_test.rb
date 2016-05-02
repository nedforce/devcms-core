require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::AbbreviationsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root = nodes(:root_section_node)
  end

  test 'should get index' do
    login_as :sjoerd

    get :index, node_id: @root.id

    assert_response :success
  end

  test 'should create abbreviation' do
    login_as :sjoerd

    assert_difference 'Abbreviation.count' do
      create_abbreviation
    end

    assert_response :success
    refute assigns(:abbreviation).new_record?, assigns(:abbreviation).errors.full_messages.join('; ')
  end

  test 'should destroy abbreviation' do
    login_as :sjoerd

    assert_difference('Abbreviation.count', -1) do
      delete :destroy, node_id: @root.id, id: abbreviations(:wmo).id, format: 'json'
    end

    assert_response :success
  end

  test 'should require original' do
    login_as :sjoerd

    assert_no_difference('Abbreviation.count') do
      create_abbreviation(abbr: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:abbreviation).new_record?
  end

  test 'should require name' do
    login_as :sjoerd

    assert_no_difference('Abbreviation.count') do
      create_abbreviation(definition: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:abbreviation).new_record?
  end

  test 'should get new tiny mce form' do
    login_as :editor

    get :new, node_id: @root.id, abbr: 'wmo'

    assert_response :success
    assert_equal abbreviations(:wmo), assigns(:abbreviations).first
    assert_select 'form div.panel_wrapper div.panel.current'
  end

  protected

  def create_abbreviation(options = {})
    post :create, node_id: @root.id, abbreviation: { abbr: 'snafu', definition: 'Situation Normal All Fizzed Up' }.merge(options)
  end
end
