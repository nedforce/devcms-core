require File.expand_path('../../test_helper.rb', __FILE__)

class ShareMailerTest < ActionMailer::TestCase
  self.use_transactional_fixtures = true

  tests ShareMailer

  def test_invitation_email
    share = Share.new(
      from_email_address: 'test@nedforce.nl',
      from_name: 'Nedforce',
      to_email_address: 'testor@nedforce.nl',
      to_name: 'Nedforce Testor',
      message: 'Test message',
      node: nodes(:yet_another_page_node)
    )

    email = ShareMailer.recommendation_email(share)
    body = email.parts.first.body

    assert email.to.to_s =~ /#{share.to_email_address}/
    assert email.subject =~ /#{share.subject}/
    assert body =~ /#{share.from_email_address}/
    assert body =~ /#{share.from_name}/
  end
end
