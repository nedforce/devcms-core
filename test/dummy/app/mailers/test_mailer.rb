class TestMailer < ActionMailer::Base
  layout 'mail'

  def test_email(options = {})
    options.reverse_merge!(
      from: 'test@example.com',
      to: 'r.j.delange@nedforce.nl',
      subject: 'Some test subject',
      some_option: 'Some test option',
      body: 'test message'
    )

    @some_variable = 'Some test variable'

    mail(options)
  end
end
