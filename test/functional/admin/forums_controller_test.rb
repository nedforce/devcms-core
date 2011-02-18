require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ForumsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_render_404_if_not_found
    login_as :sjoerd

    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_show_forum
    login_as :sjoerd    

    get :show, :id => forums(:bewoners_forum).id
    assert_response :success
    assert assigns(:forum)
    assert_equal nodes(:bewoners_forum_node), assigns(:node)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:forum)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :forum => { :title => 'foo' }
    assert_response :success
    assert assigns(:forum)
    assert_equal 'foo', assigns(:forum).title
  end

  def test_should_create_forum
    login_as :sjoerd

    assert_difference('Forum.count') do
      create_forum
      assert_response :success
      assert !assigns(:forum).new_record?, :message => assigns(:forum).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Forum.count') do
      create_forum({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:forum).new_record?
      assert_equal 'foobar', assigns(:forum).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Forum.count') do
      create_forum({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:forum).new_record?
      assert assigns(:forum).errors.on(:title)
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('Forum.count') do
      create_forum(:title => nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:forum).new_record?
    assert assigns(:forum).errors.on(:title)
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => forums(:bewoners_forum).id
    assert_response :success
    assert assigns(:forum)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => forums(:bewoners_forum).id, :forum => { :title => 'foo' }
    assert_response :success
    assert assigns(:forum)
    assert_equal 'foo', assigns(:forum).title
  end

  def test_should_update_forum
    login_as :sjoerd

    put :update, :id => forums(:bewoners_forum).id, :forum => { :title => 'updated title', :description => 'updated_body'}

    assert_response :success
    assert_equal 'updated title', assigns(:forum).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    forum     = forums(:bewoners_forum)
    old_title = forum.title
    put :update, :id => forum, :forum => { :title => 'updated title', :description => 'updated_body'}, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:forum).title
    assert_equal old_title, forum.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    forum     = forums(:bewoners_forum)
    old_title = forum.title
    put :update, :id => forum, :forum => { :title => nil, :description => 'updated_body'}, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:forum).errors.on(:title)
    assert_equal old_title, forum.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_forum
    login_as :sjoerd

    put :update, :id => forums(:bewoners_forum).id, :forum => {:title => nil}
    assert_response :unprocessable_entity
    assert assigns(:forum).errors.on(:title)
  end

  def test_should_require_roles
    assert_user_can_access  :arthur,       [ :new, :create ],  { :parent_node_id => nodes(:root_section_node).id }
    assert_user_cant_access :final_editor, [ :new, :create ],  { :parent_node_id => nodes(:economie_section_node).id }
    assert_user_cant_access :editor,       [ :new, :create ],  { :parent_node_id => nodes(:bewoners_forum_node).id }
    assert_user_can_access  :arthur,       [ :update, :edit ], { :id => forums(:bewoners_forum).id }
    assert_user_cant_access :final_editor, [ :update, :edit ], { :id => forums(:bewoners_forum).id }
    assert_user_cant_access :editor,       [ :update, :edit ], { :id => forums(:bewoners_forum).id }
  end

protected

  def create_forum(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :forum => { :title => 'Some exciting title.', :description => 'Some exciting description.' }.merge(attributes) }.merge(options)
  end
end
