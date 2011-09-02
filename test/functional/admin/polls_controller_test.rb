require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PollsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:poll)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :poll => { :title => 'foo' }
    assert_response :success
    assert assigns(:poll)
    assert_equal 'foo', assigns(:poll).title
  end

  def test_should_create_poll
    login_as :sjoerd

    assert_difference('Poll.count') do
      create_poll
      assert_response :success
      assert assigns(:poll)
      assert !assigns(:poll).new_record?, :message => assigns(:poll).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Poll.count') do
      create_poll({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:poll).new_record?
      assert_equal 'foobar', assigns(:poll).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Poll.count') do
      create_poll({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:poll).new_record?
      assert assigns(:poll).errors.on(:title)
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('Poll.count') do
      create_poll({:title => nil})
    end
    assert_response :unprocessable_entity
    assert assigns(:poll).new_record?
    assert assigns(:poll).errors.on(:title)
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => polls(:healthcare_poll).id
    assert_response :success
    assert assigns(:poll)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => polls(:healthcare_poll).id, :poll => { :title => 'foo' }
    assert_response :success
    assert assigns(:poll)
    assert_equal 'foo', assigns(:poll).title
  end
  
  def test_should_update_poll
    login_as :sjoerd
    
    put :update, :id => polls(:healthcare_poll).id, :poll => {:title => 'updated title'}
    
    assert_response :success
    assert_equal 'updated title', assigns(:poll).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    poll      = polls(:healthcare_poll)
    old_title = poll.title
    put :update, :id => poll, :poll => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:poll).title
    assert_equal old_title, poll.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    poll      = polls(:healthcare_poll)
    old_title = poll.title
    put :update, :id => poll, :poll => { :title => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:poll).errors.on(:title)
    assert_equal old_title, poll.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_poll
    login_as :sjoerd

    put :update, :id => polls(:healthcare_poll).id, :poll => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:poll).errors.on(:title)
  end

  protected

  def create_poll(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :poll => { :title => 'new title' }.merge(attributes) }.merge(options)
  end
end
