require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::AbbreviationsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root = nodes(:root_section_node)
  end

  def test_should_get_index
    login_as :sjoerd
    get :index, :node_id => @root.id
    assert_response :success
  end

  def test_should_create_abbreviation
    login_as :sjoerd

    assert_difference 'Abbreviation.count' do
      create_abbreviation
      assert_response :success
      refute assigns(:abbreviation).new_record?, assigns(:abbreviation).errors.full_messages.join('; ')
    end
  end

  def test_should_destroy_abbreviation
    login_as :sjoerd

    assert_difference('Abbreviation.count', -1) do
      delete :destroy, :node_id => @root.id, :id => abbreviations(:wmo).id, :format => 'json'
      assert_response :success
    end
  end

  def test_should_require_original
    login_as :sjoerd

    assert_no_difference('Abbreviation.count') do
      create_abbreviation(:abbr => nil)
    end
    assert_response :unprocessable_entity
    assert assigns(:abbreviation).new_record?
  end

  def test_should_require_name
    login_as :sjoerd

    assert_no_difference('Abbreviation.count') do
      create_abbreviation(:definition => nil)
    end
    assert_response :unprocessable_entity
    assert assigns(:abbreviation).new_record?
  end

  def test_should_get_new_tiny_mce_form
    login_as :editor

    get :new, :node_id => @root.id, :abbr => 'wmo'

    assert_response :success
    assert_equal abbreviations(:wmo), assigns(:abbreviations).first
    assert_select "form div.panel_wrapper div.panel.current"

  end

  protected

  def create_abbreviation(options = {})
    post :create, :node_id => @root.id, :abbreviation => {  :abbr => "snafu", :definition => "Situation Normal All Fizzed Up" }.merge(options)
  end
end
