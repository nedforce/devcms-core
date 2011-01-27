require File.dirname(__FILE__) + '/../test_helper'

class ContactFormMailerTest < ActionMailer::TestCase
  self.use_transactional_fixtures = true
  
  tests ContactFormMailer

  def test_message
    contact_form = contact_forms(:help_form)
    entered_fields = []
    entered_fields << [1, 'Naam', 'Meneer Test']
    entered_fields << [2, 'Emailadres', 'meneer_test@nedforce.nl']
    response = ContactFormMailer.create_message(contact_form, entered_fields)
    assert response.to.to_s =~ /#{contact_form.email_address}/
    assert response.body =~ /Naam/
    assert response.body =~ /meneer_test@nedforce.nl/
  end
end
