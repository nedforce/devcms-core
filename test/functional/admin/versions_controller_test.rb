require File.expand_path('../../../test_helper.rb', __FILE__)

# Functional tests for the +Admin::VersionsController+.
class Admin::VersionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    login_as :arthur
  end

  test 'should show unapproved nodes' do
    get :index

    assert_response :success
  end

  test 'should fetch unapproved nodes' do
    xhr :get, :index

    assert_response :success
  end

  test 'should approve unapproved node' do
    section = Section.create(user: User.find_by_login('root_editor'), title: 'foo', description: 'bar', parent: Node.root)
    xhr :put, :approve, id: section.versions.current.id

    assert_response :success
    assert section.reload.node.publishable?
  end

  test 'should send mail on approval' do
    comment = 'unapproved'
    editor = User.find_by_login('root_editor')

    section = Section.create(user: editor, title: 'foo', description: 'bar', parent: Node.root)

    ActionMailer::Base.deliveries = []

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      xhr :put, :approve, id: section.versions.current.id, comment: comment
      assert_response :success
    end

    assert section.reload.node.publishable?

    mail = ActionMailer::Base.deliveries.first
    assert_equal editor.email_address, mail.to[0]
    assert mail.parts.first.body =~ /#{comment}/
  end

  test 'should approve rejected node' do
    section = Section.create(user: User.find_by_login('root_editor'), title: 'foo', description: 'bar', parent: Node.root)
    section.versions.current.update_attribute(:status, Version::STATUSES[:rejected])
    xhr :put, :approve, id: section.versions.current.id

    assert_response :success
    assert section.reload.node.publishable?
  end

  test 'should reject unapproved node' do
    section = Section.create(user: User.find_by_login('root_editor'), title: 'foo', description: 'bar', parent: Node.root)
    xhr :put, :reject, id: section.versions.current.id

    assert_response :success
    assert !section.reload.node.publishable?
  end

  test 'should send mail on rejection' do
    reason = 'rejected'
    editor = User.find_by_login('root_editor')

    section = Section.create(user: editor, title: 'foo', description: 'bar', parent: Node.root)

    ActionMailer::Base.deliveries = []

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      xhr :put, :reject, id: section.versions.current.id, reason: reason
      assert_response :success
    end

    assert !section.reload.node.publishable?

    mail = ActionMailer::Base.deliveries.first
    assert_equal editor.email_address, mail.to[0]
    assert mail.parts.first.body =~ /#{reason}/
  end
end
