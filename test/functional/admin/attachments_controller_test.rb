require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AttachmentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @attachment = attachments(:besluit_attachment)
  end

  def test_should_get_show
    login_as :sjoerd
    get :show, :id => @attachment
    assert assigns(:attachment)
    assert_response :success    
    assert_equal @attachment.node, assigns(:node)
  end

  def test_should_get_previous
    @attachment.create_approved_version
    login_as :sjoerd
    get :previous, :id => @attachment
    assert_response :success
    assert assigns(:attachment)
  end

  
  def test_should_render_404_if_not_found
    login_as :sjoerd
        
    get :show, :id => -1
    assert_response :not_found
  end
  
  def test_should_get_new
    login_as :sjoerd
    get :new, :parent_node_id => nodes(:about_page_node).id
    assert_response :success
    assert assigns(:attachment)
  end
  
  def test_should_create_attachment
    login_as :sjoerd
    assert_difference('Attachment.count', 1) do
      create_attachment
      assert_response :success
      assert 'test.jpg', assigns(:attachment).filename
      assert !assigns(:attachment).new_record?, :message => assigns(:attachment).errors.full_messages.join('; ')
    end
  end

  def test_should_not_create_attachment
    login_as :sjoerd
    assert_no_difference('Attachment.count') do
      create_attachment(:title => nil)
      assert_response :unprocessable_entity
      assert assigns(:attachment).errors.on(:title)
    end   
  end
  
  def test_should_allow_custom_filename
    login_as :sjoerd
    assert_difference('Attachment.count', 1) do
      filename = "Test bestand.jpg"
      create_attachment(:filename => filename)
      assert filename, assigns(:attachment).filename
    end
  end
  
  def test_should_get_edit
    login_as :sjoerd
    get :edit, :id => attachments(:besluit_attachment).id
    assert_response :success
    assert assigns(:attachment)
  end
  
  def test_should_get_preview
    login_as :sjoerd
    besluit = attachments(:besluit_attachment)
    get :preview, :id => besluit.id
    assert_response :redirect
    assert assigns(:attachment)
    get :preview, :id => besluit.id, :basename => besluit.basename, :format => besluit.extension
    assert_response :success
  end
  
  def test_should_update_image
    login_as :sjoerd
    put :update, :id => attachments(:besluit_attachment).id, :attachment => { :title => 'updated title' }
    assert_response :success
    assert_equal 'updated title', assigns(:attachment).title
    assert_equal attachments(:besluit_attachment).content_type, assigns(:attachment).content_type
  end
  
  def test_should_not_update_image
    login_as :sjoerd
    put :update, :id => attachments(:besluit_attachment).id, :attachment => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:attachment).errors.on(:title)
  end
  
  def test_should_require_roles
    assert_user_can_access :arthur, [:new, :create], {:parent_node_id => nodes(:about_page_node).id}
    assert_user_can_access :arthur, [:update, :edit], {:id => attachments(:besluit_attachment).id}
    assert_user_cant_access :editor, [:new, :create], {:parent_node_id => nodes(:about_page_node).id}
    assert_user_cant_access :editor, [:update, :edit], {:id => attachments(:besluit_attachment).id}
    assert_user_cant_access :normal_user, [:new, :create], {:parent_node_id => nodes(:about_page_node).id}
    assert_user_cant_access :normal_user, [:update, :edit], {:id => attachments(:besluit_attachment).id}
  end
  
  protected
    def create_attachment(attributes = {}, options = {})
      post :create, {:parent_node_id => nodes(:about_page_node).id, :attachment => { :title => 'An Image', :category => "Bestanden", :uploaded_data => fixture_file_upload("files/test.jpg", 'image/jpeg', true) }.merge(attributes)}.merge(options)
    end
end
