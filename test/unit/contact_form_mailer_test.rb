require File.expand_path('../../test_helper.rb', __FILE__)

class ContactFormMailerTest < ActionMailer::TestCase
  self.use_transactional_fixtures = true

  tests ContactFormMailer

  def test_should_generate_contact_message
    contact_form = contact_forms(:help_form)
    entered_fields = []
    entered_fields << { :id => 1, :label => 'Naam', :value => 'Meneer Test' }
    entered_fields << { :id => 2, :label => 'Emailadres', :value => 'meneer_test@nedforce.nl' }
    entered_fields << { :id => 3, :label => 'Upload', :value => fixture_file_upload('files/ParkZandweerdMatrixplannen.doc', 'application/msword') }
    response = ContactFormMailer.contact_message(contact_form, entered_fields)
    assert response.to.to_s =~ /#{contact_form.email_address}/
    assert response.parts.first.body =~ /Naam/
    assert response.parts.first.body =~ /meneer_test@nedforce.nl/
  end
end
