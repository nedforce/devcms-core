require File.dirname(__FILE__) + '/../test_helper'

class ContactFormTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @help_form = contact_forms(:help_form)
    @info_form = contact_forms(:info_form)
  end

  def test_should_create_contact_form
    assert_difference('ContactForm.count') do
      cf = create_contact_form
      assert !cf.new_record?
    end
  end

  def test_should_require_title
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(:title => nil)
      assert cf.new_record?
      assert cf.errors.on(:title)
    end
  end

  def test_should_require_valid_title
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(:title => 'a')
      assert cf.new_record?
      assert cf.errors.on(:title)
    end
  end

  def test_should_require_email_address
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(:email_address => nil)
      assert cf.new_record?
      assert cf.errors.on(:email_address)
    end
  end

  def test_should_require_valid_email_address
    assert_no_difference('ContactForm.count') do
      cf = create_contact_form(:email_address => 'invalid-email-address')
      assert cf.new_record?
      assert cf.errors.on(:email_address)
    end
  end

  def test_should_return_obligatory_field_ids
    assert_equal @help_form.obligatory_field_ids.length, 3
    assert_equal @info_form.obligatory_field_ids.length, 1
  end

  protected

  def create_contact_form(options = {})
    ContactForm.create({
      :parent => nodes(:root_section_node), 
      :title => 'new contact form',
      :email_address => 'testmedewerker@nedforce.nl',
      :description_before_contact_fields => 'Below you see a contact form.',
      :description_after_contact_fields => 'Above you see a contact form.'
    }.merge(options))
  end
end