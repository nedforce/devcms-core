require File.expand_path('../../test_helper.rb', __FILE__)

class ContactFormFieldTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @help_form = contact_forms(:help_form)
    @info_form = contact_forms(:info_form)
  end

  def test_should_create_contact_form_field
    assert_difference('ContactFormField.count') do
      cff = create_contact_form_field
      refute cff.new_record?
    end
  end

  def test_should_require_label
    assert_no_difference('ContactFormField.count') do
      cff = create_contact_form_field(label: nil)
      assert cff.new_record?
      assert cff.errors[:label].any?
    end
  end

  def test_should_require_valid_label
    assert_no_difference('ContactFormField.count') do
      cff = create_contact_form_field(label: '')
      assert cff.new_record?
      assert cff.errors[:label].any?
    end
  end

  def test_should_require_field_type
    assert_no_difference('ContactFormField.count') do
      cff = create_contact_form_field(field_type: nil)
      assert cff.new_record?
      assert cff.errors[:field_type].any?
    end
  end

  def test_should_not_require_obligatory
    assert_difference('ContactFormField.count') do
      cff = create_contact_form_field(obligatory: nil)
      refute cff.new_record?
      refute cff.errors[:obligatory].any?
    end
  end

  def test_should_not_require_default_value
    assert_difference('ContactFormField.count') do
      cff = create_contact_form_field(default_value: nil)
      refute cff.new_record?
      refute cff.errors[:default_value].any?
    end
  end

  def test_should_require_position
    assert_no_difference('ContactFormField.count') do
      cff = create_contact_form_field(position: nil)
      assert cff.new_record?
      assert cff.errors[:position].any?
    end
  end

  def test_should_require_numerical_position
    assert_no_difference('ContactFormField.count') do
      cff = create_contact_form_field(position: 'Not an integer')
      assert cff.new_record?
      assert cff.errors[:position].any?
    end
  end

  def test_should_require_unique_position
    assert_difference('ContactFormField.count') do
      cff = create_contact_form_field
      refute cff.new_record?

      assert_no_difference('ContactFormField.count') do
        cff2 = create_contact_form_field
        assert cff2.new_record?
        assert cff2.errors[:position].any?
      end
    end
  end

  def test_should_not_require_unique_position_for_different_contact_forms
    assert_difference('ContactFormField.count', 2) do
      cff = create_contact_form_field
      refute cff.new_record?

      cff2 = create_contact_form_field(contact_form: @info_form)
      refute cff2.new_record?
    end
  end
  
  def test_should_allow_big_default_value_for_dropdown_field_type
    assert create_contact_form_field(field_type: 'dropdown', default_value: 'Geen onderwijs / basisonderwijs, LBO/ VBO/ VMBO (kader- en beroepsgerichte leerweg), MAVO/ eerste 3 jaar HAVO en VWO/ VMBO (theoretische en gemengde leerweg), MBO, HAVO en VWO bovenbouw / WO-propedeuse, HBO / WO-bachelor of kandidaats, WO-doctoraal of master,')    
  end

  protected

  def create_contact_form_field(options = {})
    ContactFormField.create({
      contact_form: @help_form,
      label: 'Name',
      field_type: 'textarea',
      obligatory: false,
      default_value: 'This is default text.',
      position: 10
    }.merge(options))
  end
end
