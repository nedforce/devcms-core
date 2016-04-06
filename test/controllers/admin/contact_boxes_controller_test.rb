require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::ContactBoxesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @contact_box = contact_boxes(:contact_box)
  end

  def test_should_get_show
    login_as :arthur

    get :show, :id => @contact_box.id
    assert_response :success
    assert assigns(:contact_box)
  end

  def test_should_get_new
    login_as :arthur

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:contact_box)
  end

  def test_should_create_contact_box
    login_as :arthur

    assert_difference('ContactBox.count') do
      create_contact_box
      assert_response :success
      refute assigns(:contact_box).new_record?, assigns(:contact_box).errors.full_messages.join('; ')
    end
  end

  def test_should_require_title
    login_as :arthur

    assert_no_difference('ContactBox.count') do
      create_contact_box(:title => nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:contact_box).new_record?
    assert assigns(:contact_box).errors[:title].any?
  end

  def test_should_get_edit
    login_as :arthur

    get :edit, :id => @contact_box.id
    assert_response :success
    assert assigns(:contact_box)
  end

  def test_should_update_contact_box
    login_as :arthur

    put :update, :id => @contact_box.id, :contact_box => { :title => 'updated title' }

    assert_response :success
    assert_equal 'updated title', assigns(:contact_box).title
  end

  def test_should_not_update_contact_box_with_invalid_attributes
    login_as :arthur

    put :update, :id => @contact_box.id, :contact_box => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:contact_box).errors[:title].any?
  end

  protected

  def create_contact_box(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :contact_box => {
      :title               => 'Contactbox',
      :contact_information => 'Contactinformatie',
      :default_text        => 'Standaardtekst'
    }.merge(attributes) }.merge(options)
  end
end
