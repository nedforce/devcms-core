require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +MailLink+ model.
class MailLinkTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @mail_link = links(:mail_link)
  end

  test 'should create mail link' do
    assert_difference 'MailLink.count', 1 do
      mail_link = create_mail_link
      assert_equal 'mailto:test@nedforce.nl', mail_link.mailto_link
    end
  end

  test 'should require email address' do
    assert_no_difference 'MailLink.count' do
      mail_link = create_mail_link(email_address: nil)
      assert mail_link.errors[:email_address].any?
    end
  end

  test 'should set description and title to nil if blank' do
    l1 = create_mail_link(title: '', description: '')
    refute l1.new_record?
    assert_nil l1.title
    assert_nil l1.description
    l2 = create_mail_link(title: nil, description: nil)
    refute l2.new_record?
    l2.update_attributes(user: users(:arthur), title: '', description: '')
    assert_nil l2.title
    assert_nil l2.description
  end

  test 'should require valid email address' do
    [' ', 'invalid-email-address', 'http://www.foo.com', 'invalid@'].each do |email_address|
      assert_no_difference 'MailLink.count' do
        mail_link = create_mail_link(email_address: email_address)
        assert mail_link.errors[:email_address].any?
      end
    end
  end

  test 'should return title for content title if title exists' do
    assert_equal @mail_link.title, @mail_link.content_title
  end

  test 'should return email address for content title if no title exists' do
    @mail_link.update_attribute(:title, nil)
    assert_equal @mail_link.email_address, @mail_link.content_title
  end

  test 'should not require unique title' do
    assert_difference 'MailLink.count', 2 do
      2.times do
        mail_link = create_mail_link(title: 'Non-unique title')
        refute mail_link.errors[:title].any?
      end
    end
  end

  test 'should update mail link' do
    assert_no_difference 'MailLink.count' do
      @mail_link.title = 'New title'
      @mail_link.description = 'New body'
      @mail_link.email_address = 'testor@nedforce.nl'

      assert @mail_link.save(user: users(:arthur))
    end
  end

  test 'should destroy mail link' do
    assert_difference 'MailLink.count', -1 do
      @mail_link.destroy
    end
  end

  protected

  def create_mail_link(options = {})
    MailLink.create({
      parent: nodes(:root_section_node),
      title: 'This is a mail link',
      description: 'Geen fratsen!',
      email_address: 'test@nedforce.nl'
    }.merge(options))
  end
end
