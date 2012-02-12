require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ImagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @image = images(:test_image)
  end

  def test_should_get_show
    login_as :sjoerd
    get :show, :id => @image
    assert_response :success
    assert assigns(:image)
  end

  def test_should_get_previous
    @image = Image.select_all_columns.find(@image.id)
    @image.save :user => User.find_by_login('editor')
    
    login_as :sjoerd
    get :previous, :id => @image
    assert_response :success
    assert assigns(:image)
  end

  def test_should_get_new
    login_as :sjoerd
    get :new, :parent_node_id => nodes(:about_page_node).id
    assert_response :success
    assert assigns(:image)
  end

  def test_should_create_image
    login_as :sjoerd

    assert_difference('Image.count', 1) do
      create_image
      assert_response :success
      assert !assigns(:image).new_record?, :message => assigns(:image).errors.full_messages.join('; ')
    end
  end

  def test_should_create_image_for_editor
    login_as :editor

    assert_difference 'Image.count' do
      create_image(:parent_node_id => nodes(:help_page_node).id)
      assert_response :success
      assert !assigns(:image).new_record?, :message => assigns(:image).errors.full_messages.join('; ')
    end
  end

  # Cant run this test, causes a double render error. disable respond_to_parent first to test.
#  def test_should_create_image_for_editor_js
#    login_as :editor
#
#    assert_difference 'Image.count' do
#      create_image(:parent_node_id => nodes(:help_page_node).id, :format => 'js')
#      assert_response :success
#    end
#  end

  def test_should_not_create_image
    login_as :sjoerd

    assert_no_difference('Image.count') do
      create_image(:image => { :title => nil })
      assert_response :success
      assert assigns(:image).errors.on(:title)
    end

  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => images(:test_image).id
    assert_response :success
    assert assigns(:image)
  end

  def test_should_get_preview
    login_as :sjoerd
    image = images(:test_image)
    get :preview, :id => image.id
    assert_response :success
    assert assigns(:image)
  end

  def test_should_get_thumbnail_for_editor
    login_as :editor
    image = images(:test_image_two)
    get :thumbnail, :id => image.id
    assert_response :success
    assert assigns(:image)
  end

  def test_should_update_image
    login_as :sjoerd

    put :update, :id => images(:test_image).id, :image => {:title => 'updated title'}

    assert_response :success
    assert_equal 'updated title', assigns(:image).title
  end

  def test_should_not_update_image
    login_as :sjoerd

    put :update, :id => images(:test_image).id, :image => {:title => nil}
    assert_response :unprocessable_entity
    assert assigns(:image).errors.on(:title)
  end

  def test_should_not_show_image_url_controls_to_editors
    login_as :editor

    get :new, :parent_node_id => nodes(:editor_section_node).id
    assert_response :success
    assert @response.body !=~ /image_url/

    create_image(:image => { :url => 'http://example.com'}, :parent_node_id => nodes(:editor_section_node).id)
    assert_response :success
    assert_nil assigns(:image).url
  end

  def test_should_show_frontpage_controls_to_admins
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:economie_section_node).id
    assert @response.body =~ /image_url/

    create_image(:image => { :url => 'http://example.com'})
    assert_response :success
    assert_equal 'http://example.com', assigns(:image).url
  end

  def test_should_show_frontpage_controls_to_final_editors
    login_as :final_editor

    get :new, :parent_node_id => nodes(:economie_section_node).id
    assert @response.body =~ /image_url/

    create_image(:image => { :url => 'http://example.com'}, :parent_node_id => nodes(:economie_section_node).id)
    assert_response :success
    assert_equal 'http://example.com', assigns(:image).url
  end

  def test_should_ignore_is_for_header_for_non_admin
    login_as :editor

    get :new, :parent_node_id => nodes(:editor_section_node).id
    assert_response :success

    create_image(:image => { :is_for_header => '1'}, :parent_node_id => nodes(:editor_section_node).id)
    assert_response :success
    assert !assigns(:image).is_for_header?
  end

  def test_should_allow_is_for_header_for_admin
    login_as :arthur

    get :new, :parent_node_id => nodes(:editor_section_node).id
    assert_response :success

    create_image(:image => { :is_for_header => '1'}, :parent_node_id => nodes(:editor_section_node).id)
    assert_response :success
    assert assigns(:image).is_for_header?
  end

  protected

    def create_image(attributes = {}, options = {})
      image = fixture_file_upload("files/test.jpg")
      post :create, {:parent_node_id => nodes(:about_page_node).id, :image => { :title => 'An Image', :data => image }}.merge(attributes).merge(options)
    end

end

