require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ApprovalsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
    
  def test_should_show_unapproved_nodes
    login_as :arthur
    get :index
    assert_response :success
  end
  
  def test_should_fetch_unapproved_nodes  
    login_as :arthur
    xhr :get, :index
    assert_response :success
  end
  
  def test_should_approve_unapproved_node
    login_as :arthur
    xhr :put, :approve, :id => nodes(:unapproved_page_node).id
    assert_response :success
    assert_equal "approved", pages(:unapproved_page).node.status
  end

  def test_should_send_mail_on_approval
    login_as :arthur
    comment = 'unapproved'
    node = nodes(:unapproved_page_node)
    node.update_attribute :editor, users(:editor)
    ActionMailer::Base.deliveries = []
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      xhr :put, :approve, :id => node.id, :comment => comment
      assert_response :success
      assert_equal "approved", pages(:unapproved_page).node.status
    end
    mail = ActionMailer::Base.deliveries.first
    assert_equal node.editor.email_address, mail.to[0]
    assert mail.body =~ /#{comment}/
  end

  def test_should_approve_rejected_node
    login_as :arthur    
    node = nodes(:rejected_page_node)
    node.update_attribute :editor, users(:editor)
    xhr :put, :approve, :id => node.id
    assert_response :success
    assert_equal "approved", pages(:rejected_page).node.status
  end
  
  def test_should_reject_unapproved_node
    login_as :arthur
    xhr :put, :reject, :id => nodes(:unapproved_page_node).id   
    assert_response :success
    assert_equal "rejected", pages(:unapproved_page).node.status
  end
  
  def test_should_send_mail_on_rejection
    login_as :arthur
    reason = 'unapproved'
    node = nodes(:unapproved_page_node)
    node.update_attribute :editor, users(:editor)
    ActionMailer::Base.deliveries = []
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      xhr :put, :reject, :id => node.id, :reason => reason
      assert_response :success
      assert_equal "rejected", pages(:unapproved_page).node.status
    end
    mail = ActionMailer::Base.deliveries.first
    assert_equal node.editor.email_address, mail.to[0]
    assert mail.body =~ /#{reason}/
  end
  
  def test_should_not_accept_unapprovable_node
    login_as :arthur   
    xhr :put, :approve, :id => nodes(:devcms_news_node).id   
    assert_response :unprocessable_entity
    
    xhr :put, :reject, :id => nodes(:devcms_news_node).id   
    assert_response :unprocessable_entity
  end
  
    def test_should_allow_final_editor_approval
    login_as :final_editor   
      
    xhr :put, :approve, :id => nodes(:unapproved_page_node).id
    assert_response :success
    assert_equal "approved", pages(:unapproved_page).node.status
  end
  
  def test_should_not_allow_editors
    assert_user_can_access :arthur, [:index, :approve, :reject]
    assert_user_can_access :final_editor, [:index, :approve, :reject]
    assert_user_cant_access :editor, [:index, :approve, :reject]
  end
  
  def test_should_get_approvable_xml
    login_as :arthur
    xhr :get, :index, :format => 'xml'
    
    # Two unapproved pages, one unapproved newsletter edition, three calendaritem and one agendaitem, two links
    expected_approvals = [
      nodes(:unapproved_page_node),
      nodes(:rejected_page_node),
      nodes(:newsletter_edition_volgend_jaar_node),
      nodes(:events_calendar_item_two_node),
      nodes(:agenda_item_three_node),
      nodes(:unapproved_external_link_node),
      nodes(:unapproved_internal_link_node),
      nodes(:unapproved_calendar_item_node),
      nodes(:unapproved_meeting_node)
    ]
    
    assert assigns(:approvals).set_equals?(expected_approvals)
    assert_response :success
  end
    
  def test_should_set_edited_by_upon_approval
    login_as :arthur
    xhr :put, :approve, :id => nodes(:unapproved_page_node).id
    assert_response :success
    assert_equal "approved", pages(:unapproved_page).node.status 
    assert_equal users(:arthur), pages(:unapproved_page).node.editor
  end
end
