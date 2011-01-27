require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ContactFormsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_render_404_if_not_found
    login_as :sjoerd

    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:contact_form)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id,
              :contact_form => { :email_address => 'test@nedforce.nl', :title => 'foo',
                                 :description_before_contact_fields => 'De contactvelden staan hieronder.',
                                 :description_after_contact_fields => 'De contactvelden staan hierboven.' }
    assert_response :success
    assert assigns(:contact_form)
    assert_equal 'test@nedforce.nl', assigns(:contact_form).email_address
    assert_equal 'foo', assigns(:contact_form).title
  end

  def test_should_create_contact_form
    login_as :sjoerd

    assert_difference('ContactForm.count') do
      create_contact_form
      assert_response :success
      assert assigns(:contact_form)
      assert !assigns(:contact_form).new_record?, :message => assigns(:contact_form).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('ContactForm.count') do
      create_contact_form({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:contact_form).new_record?
      assert_equal 'foobar', assigns(:contact_form).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('ContactForm.count') do
      create_contact_form({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
    end

    assert assigns(:contact_form).new_record?
    assert assigns(:contact_form).errors.on(:title)
    assert_template 'new'
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('ContactForm.count') do
      create_contact_form({ :title => nil })
    end

    assert_response :unprocessable_entity
    assert assigns(:contact_form).new_record?
    assert assigns(:contact_form).errors.on(:title)
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => contact_forms(:help_form).id
    assert_response :success
    assert assigns(:contact_form)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => contact_forms(:help_form).id, :contact_form => { :title => 'foo' }
    assert_response :success
    assert assigns(:contact_form)
    assert_equal 'testmedewerker@nedforce.nl', assigns(:contact_form).email_address
    assert_equal 'foo', assigns(:contact_form).title
  end

  def test_should_update_contact_form
    login_as :sjoerd

    put :update, :id => contact_forms(:help_form).id, :contact_form => {:title => 'updated title'}

    assert_response :success
    assert_equal 'updated title', assigns(:contact_form).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    contact_form = contact_forms(:help_form)
    old_title    = contact_form.title
    put :update, :id => contact_form, :contact_form => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:contact_form).title
    assert_equal old_title, contact_form.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    contact_form = contact_forms(:help_form)
    old_title    = contact_form.title
    put :update, :id => contact_form, :contact_form => { :title => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:contact_form).errors.on(:title)
    assert_equal old_title, contact_form.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_contact_form
    login_as :sjoerd

    put :update, :id => contact_forms(:help_form).id, :contact_form => {:title => nil}
    assert_response :unprocessable_entity
    assert assigns(:contact_form).errors.on(:title)
  end

  protected

  def create_contact_form(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id,
         :contact_form => { :email_address => 'test@nedforce.nl', :title => 'new title',
                            :description_before_contact_fields => 'Test omschrijving boven.',
                            :description_after_contact_fields  => 'Test omschrijving onder.'}.merge(attributes) }.merge(options)
  end
end
