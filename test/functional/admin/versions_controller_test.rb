require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::VersionsControllerTest < ActionController::TestCase
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
    section = Section.create(:user => User.find_by_login('root_editor'), :title => 'foo', :description => 'bar', :parent => Node.root)
    
    login_as :arthur
    xhr :put, :approve, :id => section.versions.current.id
    assert_response :success
    assert section.reload.node.publishable?
  end

  def test_should_send_mail_on_approval
    login_as :arthur
    
    comment = 'unapproved'
    editor = User.find_by_login('root_editor')
    
    section = Section.create(:user => editor, :title => 'foo', :description => 'bar', :parent => Node.root)
    
    ActionMailer::Base.deliveries = []
    
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      xhr :put, :approve, :id => section.versions.current.id, :comment => comment
      assert_response :success
    end
    
    assert section.reload.node.publishable?
    
    mail = ActionMailer::Base.deliveries.first
    assert_equal editor.email_address, mail.to[0]
    assert mail.parts.first.body =~ /#{comment}/
  end

  def test_should_approve_rejected_node
    section = Section.create(:user => User.find_by_login('root_editor'), :title => 'foo', :description => 'bar', :parent => Node.root)
    section.versions.current.update_attribute(:status, Version::STATUSES[:rejected])
    
    login_as :arthur
    xhr :put, :approve, :id => section.versions.current.id
    assert_response :success
    assert section.reload.node.publishable?
  end
  
  def test_should_reject_unapproved_node
    section = Section.create(:user => User.find_by_login('root_editor'), :title => 'foo', :description => 'bar', :parent => Node.root)
    
    login_as :arthur
    xhr :put, :reject, :id => section.versions.current.id
    assert_response :success
    assert !section.reload.node.publishable?
  end
  
  def test_should_send_mail_on_rejection
    login_as :arthur
    
    reason = 'rejected'
    editor = User.find_by_login('root_editor')
    
    section = Section.create(:user => editor, :title => 'foo', :description => 'bar', :parent => Node.root)
    
    ActionMailer::Base.deliveries = []
    
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      xhr :put, :reject, :id => section.versions.current.id, :reason => reason
      assert_response :success
    end
    
    assert !section.reload.node.publishable?
    
    mail = ActionMailer::Base.deliveries.first
    assert_equal editor.email_address, mail.to[0]
    assert mail.parts.first.body =~ /#{reason}/
  end
end
