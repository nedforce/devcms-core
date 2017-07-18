require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::AgendaItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    login_as :sjoerd
  end

  test 'should show agenda item' do
    get :show, id: agenda_items(:agenda_item_one).id

    assert assigns(:agenda_item)
    assert_response :success
    assert_equal nodes(:agenda_item_one_node), assigns(:node)
  end

  test 'should get new' do
    get :new, parent_node_id: nodes(:meetings_calendar_meeting_one_node).id

    assert_response :success
    assert assigns(:agenda_item)
  end

  test 'should get new with params' do
    get :new, parent_node_id: nodes(:meetings_calendar_meeting_one_node).id, agenda_item: { body: 'foo' }

    assert_response :success
    assert assigns(:agenda_item)
    assert_equal 'foo', assigns(:agenda_item).body
  end

  test 'should create agenda item' do
    assert_difference('AgendaItem.count') do
      create_agenda_item
    end

    assert_response :success
    refute assigns(:agenda_item).new_record?, assigns(:agenda_item).errors.full_messages.join('; ')
  end

  test 'should get valid preview for create' do
    assert_no_difference('AgendaItem.count') do
      create_agenda_item({ body: 'foobar' }, commit_type: 'preview')
    end

    assert_response :success
    assert assigns(:agenda_item).new_record?
    assert_equal 'foobar', assigns(:agenda_item).body
    assert_template 'create_preview'
  end

  test 'should not get invalid preview for create' do
    assert_no_difference('AgendaItem.count') do
      create_agenda_item({ description: nil }, commit_type: 'preview')
    end

    assert_response :unprocessable_entity
    assert assigns(:agenda_item).new_record?
    assert assigns(:agenda_item).errors[:description].any?
    assert_template 'new'
  end

  test 'should require description' do
    assert_no_difference('AgendaItem.count') do
      create_agenda_item(description: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:agenda_item).new_record?
    assert assigns(:agenda_item).errors[:description].any?
  end

  test 'should get edit' do
    get :edit, id: agenda_items(:agenda_item_one).id

    assert_response :success
    assert assigns(:agenda_item)
  end

  test 'should get edit with params' do
    get :edit, id: agenda_items(:agenda_item_one).id, agenda_item: { body: 'foo' }

    assert_response :success
    assert assigns(:agenda_item)
    assert_equal 'foo', assigns(:agenda_item).body
  end

  test 'should update agenda item' do
    put :update, id: agenda_items(:agenda_item_one).id, agenda_item: { description: 'updated title', body: 'updated body' }

    assert_response :success
    assert_equal 'updated title', assigns(:agenda_item).description
  end

  test 'should get valid preview for update' do
    agenda_item = agenda_items(:agenda_item_two)
    old_body = agenda_item.body
    put :update, id: agenda_item, agenda_item: { body: 'updated body' }, commit_type: 'preview'

    assert_response :success
    assert_equal 'updated body', assigns(:agenda_item).body
    assert_equal old_body, agenda_item.reload.body
    assert_template 'update_preview'
  end

  test 'should not get invalid preview for update' do
    agenda_item = agenda_items(:agenda_item_one)
    old_description = agenda_item.description
    put :update, id: agenda_item, agenda_item: { description: nil }, commit_type: 'preview'

    assert_response :unprocessable_entity
    assert assigns(:agenda_item).errors[:description].any?
    assert_equal old_description, agenda_item.reload.description
    assert_template 'edit'
  end

  test 'should not update agenda item with invalid title' do
    put :update, id: agenda_items(:agenda_item_one).id, agenda_item: { description: nil }

    assert_response :unprocessable_entity
    assert assigns(:agenda_item).errors[:description].any?
  end

  protected

  def create_agenda_item(attributes = {}, options = {})
    post :create, {
      parent_node_id: nodes(:meetings_calendar_meeting_one_node).id,
      agenda_item: {
        description: 'description',
        body: 'Lorem ipsum',
        agenda_item_category_name: agenda_item_categories(:hamerstukken).name
      }.merge(attributes)
    }.merge(options)
  end
end
