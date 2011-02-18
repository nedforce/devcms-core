require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AgendaItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_agenda_item
    login_as :sjoerd
    
    get :show, :id => agenda_items(:agenda_item_one).id

    assert assigns(:agenda_item)
    assert_response :success
    assert_equal nodes(:agenda_item_one_node), assigns(:node)
  end
 
  def test_should_render_404_if_not_found
    login_as :sjoerd
        
    get :show, :id => -1
    assert_response :not_found
  end  
  
  def test_should_get_new
    login_as :sjoerd
    
    get :new, :parent_node_id => nodes(:meetings_calendar_meeting_one_node).id
    assert_response :success
    assert assigns(:agenda_item)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:meetings_calendar_meeting_one_node).id, :agenda_item => { :body => 'foo' }
    assert_response :success
    assert assigns(:agenda_item)
    assert_equal 'foo', assigns(:agenda_item).body
  end
  
  def test_should_create_agenda_item
    login_as :sjoerd
    
    assert_difference('AgendaItem.count') do
      create_agenda_item
      assert_response :success
      assert !assigns(:agenda_item).new_record?, :message => assigns(:agenda_item).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('AgendaItem.count') do
      create_agenda_item({ :body => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:agenda_item).new_record?
      assert_equal 'foobar', assigns(:agenda_item).body
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('AgendaItem.count') do
      create_agenda_item({ :description => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:agenda_item).new_record?
      assert assigns(:agenda_item).errors.on(:description)
      assert_template 'new'
    end
  end
  
  def test_should_require_description
    login_as :sjoerd
    
    assert_no_difference('AgendaItem.count') do
      create_agenda_item(:description => nil)
    end
    
    assert_response :unprocessable_entity
    assert assigns(:agenda_item).new_record?
    assert assigns(:agenda_item).errors.on(:description)
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => agenda_items(:agenda_item_one).id
    assert_response :success
    assert assigns(:agenda_item)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => agenda_items(:agenda_item_one).id, :agenda_item => { :body => 'foo' }
    assert_response :success
    assert assigns(:agenda_item)
    assert_equal 'foo', assigns(:agenda_item).body
  end
  
  def test_should_update_agenda_item
    login_as :sjoerd
    
    put :update, :id => agenda_items(:agenda_item_one).id, :agenda_item => { :description => 'updated title', :body => 'updated body' }
    
    assert_response :success
    assert_equal 'updated title', assigns(:agenda_item).description
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    agenda_item = agenda_items(:agenda_item_one)
    old_body = agenda_item.body
    put :update, :id => agenda_item, :agenda_item => { :body => 'updated body' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated body', assigns(:agenda_item).body
    assert_equal old_body, agenda_item.reload.body
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    agenda_item = agenda_items(:agenda_item_one)
    old_description = agenda_item.description
    put :update, :id => agenda_item, :agenda_item => { :description => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:agenda_item).errors.on(:description)
    assert_equal old_description, agenda_item.reload.description
    assert_template 'edit'
  end
  
  def test_should_not_update_agenda_item_with_invalid_title
    login_as :sjoerd
    
    put :update, :id => agenda_items(:agenda_item_one).id, :agenda_item => { :description => nil }
    assert_response :unprocessable_entity
    assert assigns(:agenda_item).errors.on(:description)
  end
  
  def test_should_require_roles
    assert_user_can_access :arthur,       [ :new, :create ],  { :parent_node_id => nodes(:meetings_calendar_meeting_one_node).id }
    assert_user_can_access :final_editor, [ :new, :create ],  { :parent_node_id => nodes(:meetings_calendar_meeting_one_node).id }
    assert_user_can_access :editor,       [ :new, :create ],  { :parent_node_id => nodes(:meetings_calendar_meeting_one_node).id }
    assert_user_can_access :arthur,       [ :update, :edit ], { :id => agenda_items(:agenda_item_one).id }
    assert_user_can_access :final_editor, [ :update, :edit ], { :id => agenda_items(:agenda_item_one).id }
    assert_user_can_access :editor,       [ :update, :edit ], { :id => agenda_items(:agenda_item_one).id }
  end

protected
  
  def create_agenda_item(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:meetings_calendar_meeting_one_node).id, :agenda_item => { :description => 'description', :body => 'Lorem ipsum', :agenda_item_category_name => agenda_item_categories(:hamerstukken).name }.merge(attributes)}.merge(options)
  end
end