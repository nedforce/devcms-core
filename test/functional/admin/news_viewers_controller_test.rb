require File.dirname(__FILE__) + '/../../test_helper'

class Admin::NewsViewersControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @news_viewer = create_news_viewer
  end

  def test_should_render_404_if_not_found
    login_as :sjoerd

    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_show_news_viewer
    login_as :sjoerd

    get :show, :id => @news_viewer.id
    assert_response :success
    assert assigns(:news_viewer)
    assert assigns(:news_items)
    assert assigns(:news_items_for_table)
    assert assigns(:latest_news_items)      
    assert_equal @news_viewer.node, assigns(:node)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:news_viewer)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :news_viewer => { :title => 'foo' }
    assert_response :success
    assert assigns(:news_viewer)
    assert_equal 'foo', assigns(:news_viewer).title
  end

  def test_should_create_news_viewer
    login_as :sjoerd

    assert_difference('NewsViewer.count') do
      create_news_viewer
      assert_response :success
      assert !assigns(:news_viewer).new_record?, :message => assigns(:news_viewer).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsViewer.count') do
      create_news_viewer({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:news_viewer).new_record?
      assert_equal 'foobar', assigns(:news_viewer).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsViewer.count') do
      create_news_viewer({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:news_viewer).new_record?
      assert assigns(:news_viewer).errors.on(:title)
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('NewsViewer.count') do
      create_news_viewer({ :title => nil })
    end

    assert_response :unprocessable_entity
    assert assigns(:news_viewer).new_record?
    assert assigns(:news_viewer).errors.on(:title)
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => @news_viewer
    assert_response :success
    assert assigns(:news_viewer)
  end

  def test_should_get_edit_items
    login_as :sjoerd

    get :edit_items, :id => @news_viewer
    assert_response :success
    assert assigns(:news_archives)
  end  

  def test_should_update_news_viewer
    login_as :sjoerd

    put :update, :id => @news_viewer, :news_viewer => { :title => 'updated title', :description => 'updated description' }

    assert_response :success
    assert_equal 'updated title', assigns(:news_viewer).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    old_title = @news_viewer.title
    put :update, :id => @news_viewer, :news_viewer => { :title => 'updated title', :description => 'updated description' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:news_viewer).title
    assert_equal old_title, @news_viewer.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    old_title = @news_viewer.title
    put :update, :id => @news_viewer, :news_viewer => { :title => nil, :description => 'updated description' }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:news_viewer).errors.on(:title)
    assert_equal old_title, @news_viewer.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_news_viewer
    login_as :sjoerd

    put :update, :id => @news_viewer.id, :news_viewer => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:news_viewer).errors.on(:title)
  end

  def test_should_require_roles
    assert_user_can_access  :arthur,       [ :new, :create ],  { :parent_node_id => nodes(:root_section_node).id }
    assert_user_can_access  :final_editor, [ :new, :create ],  { :parent_node_id => nodes(:economie_section_node).id }
    assert_user_cant_access :editor,       [ :new, :create ],  { :parent_node_id => nodes(:root_section_node).id }

    assert_user_can_access  :arthur,       [ :update, :edit ], { :id => @news_viewer.id}
    assert_user_can_access  :final_editor, [ :update, :edit ], { :id => @news_viewer.id}
    assert_user_cant_access :editor,       [ :update, :edit ], { :id => @news_viewer.id}
  end

protected

  def create_news_viewer(attributes = {}, options = {})
    login_as :sjoerd    
    post :create, { :parent_node_id => nodes(:economie_section_node).id, :commit_type => 'save', :news_viewer => { :title => 'NewsViewer', :description => 'A News Viewer' }.merge(attributes) }.merge(options)
    assigns(:news_viewer)
  end
end
