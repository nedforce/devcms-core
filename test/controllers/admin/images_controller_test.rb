require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::ImagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    ImageUploader.any_instance.stubs(:blank?).returns(false)
    ImageUploader.any_instance.stubs(:path).returns(File.join(File.dirname(__FILE__), '../../fixtures/files/test.jpg'))
    @image = images(:test_image)
  end

  test 'should get show' do
    login_as :sjoerd

    get :show, id: @image

    assert_response :success
    assert assigns(:image)
  end

  test 'should get previous' do
    @image = Image.find(@image.id)
    @image.save user: User.find_by_login('editor')
    login_as :sjoerd

    get :previous, id: @image

    assert_response :success
    assert assigns(:image)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, parent_node_id: nodes(:about_page_node).id

    assert_response :success
    assert assigns(:image)
  end

  test 'should create image' do
    login_as :sjoerd

    assert_difference('Image.count', 1) do
      create_image
    end

    assert_response :success
    refute assigns(:image).new_record?, assigns(:image).errors.full_messages.join('; ')
  end

  def test_should_create_image_for_editor
    login_as :editor

    assert_difference 'Image.count' do
      create_image(parent_node_id: nodes(:help_page_node).id)
    end

    assert_response :success
    refute assigns(:image).new_record?, assigns(:image).errors.full_messages.join('; ')
  end

  test 'should create image for editor js' do
    login_as :editor

    assert_difference 'Image.count' do
      create_image(parent_node_id: nodes(:help_page_node).id, format: 'js')
    end

    assert_response :success
  end

  test 'should not create image' do
    login_as :sjoerd

    assert_no_difference('Image.count') do
      create_image(image: { title: nil })
    end

    assert_response :success
    assert assigns(:image).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, id: images(:test_image).id

    assert_response :success
    assert assigns(:image)
  end

  test 'should get preview' do
    login_as :sjoerd
    image = images(:test_image)

    get :preview, id: image.id

    assert_response :success
    assert assigns(:image)
  end

  test 'should get thumbnail for editor' do
    login_as :editor
    image = images(:test_image_two)

    get :thumbnail, id: image.id

    assert_response :success
    assert assigns(:image)
  end

  test 'should update image' do
    login_as :sjoerd

    put :update, id: images(:test_image).id, image: { title: 'updated title' }

    assert_response :success
    assert_equal 'updated title', assigns(:image).title
  end

  test 'should not update image' do
    login_as :sjoerd

    put :update, id: images(:test_image).id, image: { title: nil }
    assert_response :unprocessable_entity
    assert assigns(:image).errors[:title].any?
  end

  test 'should not show image url controls to editors' do
    login_as :editor

    get :new, parent_node_id: nodes(:editor_section_node).id
    assert_response :success
    assert @response.body !~ /image_url/

    create_image(image: { url: 'http://test.host' }, parent_node_id: nodes(:editor_section_node).id)
    assert_response :success
    assert_nil assigns(:image).url
  end

  test 'should show frontpage controls to admins' do
    login_as :sjoerd

    get :new, parent_node_id: nodes(:economie_section_node).id
    assert @response.body =~ /image_url/

    create_image(image: { url: 'http://test.host' })
    assert_response :success
    assert_equal 'http://test.host', assigns(:image).url
  end

  test 'should show frontpage controls to final editor' do
    login_as :final_editor

    get :new, parent_node_id: nodes(:economie_section_node).id
    assert @response.body =~ /image_url/

    create_image(image: { url: 'http://test.host' }, parent_node_id: nodes(:economie_section_node).id)
    assert_response :success
    assert_equal 'http://test.host', assigns(:image).url
  end

  test 'should ignore is for header for non-admin' do
    login_as :editor

    get :new, parent_node_id: nodes(:editor_section_node).id
    assert_response :success

    create_image(image: { is_for_header: '1' }, parent_node_id: nodes(:editor_section_node).id)
    assert_response :success
    refute assigns(:image).is_for_header?
  end

  test 'should allow is for header for admin' do
    login_as :arthur

    get :new, parent_node_id: nodes(:editor_section_node).id
    assert_response :success

    create_image(image: { is_for_header: '1' }, parent_node_id: nodes(:editor_section_node).id)
    assert_response :success
    assert assigns(:image).is_for_header?
  end

  protected

  def create_image(attributes = {}, options = {})
    post :create, {
      parent_node_id: nodes(:about_page_node).id,
      image: {
        title: 'An Image',
        file: fixture_file_upload('files/test.jpg')
      }
    }.merge(attributes).merge(options)
  end
end
