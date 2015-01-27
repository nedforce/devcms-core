require File.expand_path('../../test_helper.rb', __FILE__)

class ContactFormTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  test 'should create contact form' do
    assert_difference('ContactForm.count') do
      cf = create_contact_form
      assert !cf.new_record?
    end
  end

  test 'should require title' do
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(title: nil)
      assert cf.new_record?
      assert cf.errors[:title].any?
    end
  end

  test 'should require valid title' do
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(title: '')
      assert cf.new_record?
      assert cf.errors[:title].any?
    end
  end

  test 'should require email address' do
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(email_address: nil)
      assert cf.new_record?
      assert cf.errors[:email_address].any?
    end
  end

  test 'should require valid email address' do
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(email_address: 'invalid-email-address')
      assert cf.new_record?
      assert cf.errors[:email_address].any?
    end
  end

  test 'should return obligatory_field_ids' do
    assert_equal contact_forms(:help_form).obligatory_field_ids.length, 3
    assert_equal contact_forms(:info_form).obligatory_field_ids.length, 1
  end

  protected

  def create_contact_form(options = {})
    ContactForm.create({
      parent:                            nodes(:root_section_node),
      title:                             'new contact form',
      email_address:                     'testmedewerker@nedforce.nl',
      description_before_contact_fields: 'Below you see a contact form.',
      description_after_contact_fields:  'Above you see a contact form.'
    }.merge(options))
  end
end
