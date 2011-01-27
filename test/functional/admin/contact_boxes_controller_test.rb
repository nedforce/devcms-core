require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ContactBoxesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @contact_box = contact_boxes(:contact_box)
  end

  def test_should_get_show
    login_as :arthur

    get :show, :id => @contact_box.id
    assert_response :success
    assert assigns(:contact_box)
  end

  def test_should_render_404_if_not_found
    login_as :arthur

    get :show, :id => -1
    assert_response :not_found
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
      assert !assigns(:contact_box).new_record?, :message => assigns(:contact_box).errors.full_messages.join('; ')
    end
  end

  def test_should_require_title
    login_as :arthur

    assert_no_difference('ContactBox.count') do
      create_contact_box(:title => nil)
    end
    
    assert_response :unprocessable_entity
    assert assigns(:contact_box).new_record?
    assert assigns(:contact_box).errors.on(:title)
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
    assert assigns(:contact_box).errors.on(:title)
  end

  def test_should_require_roles
    assert_user_can_access  :arthur,       [ :new, :create ],  { :parent_node_id => nodes(:root_section_node) }
    assert_user_cant_access :final_editor, [ :new, :create ],  { :parent_node_id => nodes(:economie_section_node) }
    assert_user_cant_access :editor,       [ :new, :create ],  { :parent_node_id => nodes(:root_section_node) }

    assert_user_can_access  :arthur,       [ :update, :edit ], { :id => @contact_box }
    assert_user_cant_access :final_editor, [ :update, :edit ], { :id => @contact_box }
    assert_user_cant_access :editor,       [ :update, :edit ], { :id => @contact_box }
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
