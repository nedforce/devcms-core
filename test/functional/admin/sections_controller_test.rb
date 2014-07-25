require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::SectionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @editor_section = sections(:editor_section)
  end

  def test_should_get_show
    login_as :sjoerd

    get :show, :id => @editor_section
    assert_response :success
    assert assigns(:section)
  end

  def test_should_get_previous
    @editor_section.save :user => User.find_by_login('editor')

    login_as :sjoerd

    get :previous, :id => @editor_section
    assert_response :success
    assert assigns(:section)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:section)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :section => { :title => 'foo' }
    assert_response :success
    assert assigns(:section)
    assert_equal 'foo', assigns(:section).title
  end

  def test_should_create_section
    login_as :sjoerd

    assert_difference('Section.count') do
      create_section
      assert_response :success
      assert !assigns(:section).new_record?, assigns(:section).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Section.count') do
      create_section({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:section).new_record?
      assert_equal 'foobar', assigns(:section).title
      assert_template 'create_preview'
    end

  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Section.count') do
      create_section({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:section).new_record?
      assert assigns(:section).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_not_create_section
    login_as :sjoerd

    assert_no_difference('Section.count') do
      create_section({ :title => nil })
    end
    assert_response :unprocessable_entity
    assert assigns(:section).new_record?
    assert assigns(:section).errors[:title].any?
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => sections(:economie_section).id
    assert_response :success
    assert assigns(:section)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => sections(:economie_section).id, :section => { :title => 'foo' }
    assert_response :success
    assert assigns(:section)
    assert_equal 'foo', assigns(:section).title
  end
  
  def test_should_update_section
    login_as :sjoerd
    
    put :update, :id => sections(:economie_section).id, :section => { :title => 'updated title', :description => 'updated_body' }
    
    assert_response :success
    assert_equal 'updated title', assigns(:section).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    section = sections(:economie_section)
    old_title = section.title
    put :update, :id => section.id, :section => { :title => 'updated title', :description => 'updated_body' }, :commit_type => 'preview'
    assert_response :success
    assert_equal 'updated title', assigns(:section).title
    assert_equal old_title, section.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    section = sections(:economie_section)
    old_title = section.title
    put :update, :id => section.id, :section => { :title => nil, :description => 'updated_body' }, :commit_type => 'preview'
    assert_response :unprocessable_entity
    assert assigns(:section).errors[:title].any?
    assert_equal old_title, section.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_section
    login_as :sjoerd

    put :update, :id => sections(:economie_section).id, :section => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:section).errors[:title].any?
  end

  def test_should_not_show_frontpage_controls_to_editors
    login_as :editor

    get :edit, :id => sections(:editor_section).id
    assert_response :success
    assert @response.body !=~ /frontpage_node_id/
    assert_nil assigns(:section).frontpage_node_id

    put :update, :id => sections(:editor_section).id, :section => { :frontpage_node_id => nodes(:editor_section_page_node).id }
    assert_response :success
    assert_nil assigns(:section).frontpage_node_id
  end

  def test_should_show_frontpage_controls_to_admins
    login_as :sjoerd

    get :edit, :id => sections(:economie_section).id
    assert @response.body =~ /frontpage_node_id/
    assert_nil assigns(:section).frontpage_node_id

    put :update, :id => sections(:economie_section).id, :section => { :frontpage_node_id => nodes(:economie_poll_node).id }
    assert_response :success
    assert_equal nodes(:economie_poll_node).id, assigns(:section).frontpage_node_id
  end

  def test_should_show_frontpage_controls_to_final_editors
    login_as :final_editor

    get :edit, :id => sections(:economie_section).id
    assert @response.body =~ /frontpage_node_id/
    assert_nil assigns(:section).frontpage_node_id

    put :update, :id => sections(:economie_section).id, :section => { :frontpage_node_id => nodes(:economie_poll_node).id }
    assert_response :success
    assert_equal nodes(:economie_poll_node).id, assigns(:section).frontpage_node_id
  end

  def test_should_set_publication_start_date_on_create
    login_as :sjoerd

    assert_difference('Section.count') do
      date = 1.year.from_now
      create_section :publication_start_date => date
      assert_response :success
      assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:section).publication_start_date
    end
  end

  def test_should_set_publication_start_date_on_update
    login_as :sjoerd

    date = 1.year.from_now

    put :update, :id => sections(:economie_section),
                 :section => { :publication_start_date_day => date.strftime("%d-%m-%Y"), :publication_start_date_time => date.strftime("%H:%M") }

    assert_response :success
    assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:section).publication_start_date
  end

protected

  def create_section(attributes = {}, options = {})
    publication_start_date = attributes.delete(:publication_start_date) || Time.now
    post :create, { :parent_node_id => nodes(:root_section_node).id, :section => { :title => 'new title', :description => 'Lorem ipsum', :publication_start_date_day => publication_start_date.strftime("%d-%m-%Y"), :publication_start_date_time => publication_start_date.strftime("%H:%M") }.merge(attributes) }.merge(options)
  end
end
