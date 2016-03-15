require File.expand_path('../../test_helper.rb', __FILE__)

class NodeExpirationMailerWorkerTest < ActionMailer::TestCase
  setup do
    n1 = nodes(:editor_section_page_node)
    n1.responsible_user = users(:editor)
    n1.expires_on = 5.days.ago
    n1.save(validate: false)

    n2 = nodes(:help_page_node)
    n2.responsible_user = users(:editor)
    n2.expires_on = 2.days.ago
    n2.save(validate: false)

    n4 = nodes(:contact_page_node)
    n4.responsible_user = users(:final_editor)
    n4.expires_on = 2.weeks.ago
    n4.save(validate: false)
  end

  test 'should notify authors' do
    assert_equal 3, Node.expired.count
    assert_difference('ActionMailer::Base.deliveries.size', 3) do
      NodeExpirationMailerWorker.notify_authors
      assert ActionMailer::Base.deliveries.all? { |message| message.subject.include? 'Content onder uw beheer' }
    end
  end

  test 'should use parent subject' do
    assert Node.root.content.update_attribute :expiration_email_subject, 'Aangepast onderwerp'
    assert_difference('ActionMailer::Base.deliveries.size', 3) do
      NodeExpirationMailerWorker.notify_authors
      assert ActionMailer::Base.deliveries.all? { |message| message.subject.include? 'Aangepast onderwerp' }
    end
  end

  test 'should notify final editors' do
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      NodeExpirationMailerWorker.notify_final_editors
      assert ActionMailer::Base.deliveries.all? { |message| message.subject.include? 'Content onder uw beheer' }
    end
  end

  test 'should notify with inheritance and email' do
    nodes(:feedback_page_node).update_attribute :expires_on, 2.weeks.ago
    assert_difference('ActionMailer::Base.deliveries.size', 4) do
      NodeExpirationMailerWorker.notify_authors
    end
  end
end
