require File.expand_path('../../test_helper.rb', __FILE__)

class ContactBoxTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_node = nodes(:root_section_node)
  end

  def test_should_create_contact_box
    assert_difference('ContactBox.count') do
      create_contact_box
    end
  end

  def test_should_require_title
    assert_no_difference('ContactBox.count') do
      contact_box = create_contact_box(:title => nil)
      assert contact_box.errors[:title].any?
    end
  end

  def test_should_require_contact_information
    assert_no_difference('ContactBox.count') do
      contact_box = create_contact_box(:contact_information => nil)
      assert contact_box.errors[:contact_information].any?
    end
  end

  def test_should_require_default_text
    assert_no_difference('ContactBox.count') do
      contact_box = create_contact_box(:default_text => nil)
      assert contact_box.errors[:default_text].any?
    end
  end

  def test_should_not_require_daily_override_texts
    [ :monday_text, :tuesday_text, :wednesday_text, :thursday_text, :friday_text ].each do |field|
      assert_difference('ContactBox.count') do
        contact_box = create_contact_box(field => nil)
        assert contact_box.errors[field].empty?
      end
    end
  end

  def test_should_require_daily_override_texts_to_have_the_proper_length
    [ :monday_text, :tuesday_text, :wednesday_text, :thursday_text, :friday_text ].each do |field|
      assert_no_difference('ContactBox.count') do
        contact_box = create_contact_box(field => 'a')
        assert contact_box.errors[field].any?
      end
    end
  end

  def test_should_update_page
    contact_box = create_contact_box

    assert_no_difference('ContactBox.count') do
      contact_box.default_text = 'New default text'
      assert contact_box.save
    end
  end

  def test_should_destroy_page
    contact_box = create_contact_box

    assert_difference('ContactBox.count', -1) do
      contact_box.destroy
    end
  end

  protected

  def create_contact_box(options = {})
    ContactBox.create({
      :parent              => @root_node,
      :title               => 'Contactinformatie',
      :contact_information => 'Contact info',
      :default_text        => 'Interesting default text'
    }.merge(options))
  end
end
