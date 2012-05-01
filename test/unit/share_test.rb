require File.expand_path('../../test_helper.rb', __FILE__)

class ShareTest < ActiveSupport::TestCase

  def test_should_create_valid_share
    # We cannot assert_difference on the model, because share is not really an ActiveRecord model.
    share = create_share
    assert share.valid?
  end

  def test_should_require_from_email_address
    share = create_share(:from_email_address => nil)
    assert !share.valid?
  end

  def test_should_require_from_name
    share = create_share(:from_name => nil)
    assert !share.valid?
  end

  def test_should_require_to_email_address
    share = create_share(:to_email_address => nil)
    assert !share.valid?
  end

  def test_should_require_to_name
    share = create_share(:to_name => nil)
    assert !share.valid?
  end

  def test_should_require_message
    share = create_share(:message => nil)
    assert !share.valid?
  end

  def test_should_require_node
    share = create_share(:node => nil)
    assert !share.valid?
  end

  def test_should_return_subject
    share = create_share
    assert_equal share.subject, 'Yet'
  end

  def test_should_send_recommendation_email
    share = create_share
    assert_difference 'ActionMailer::Base.deliveries.size' do
      share.send_recommendation_email
    end
  end

  protected

  def create_share(options = {})
    Share.new({ :from_email_address => 'test@nedforce.nl', :from_name => 'Nedforce test',
                :to_email_address => 'paas@haas.nl', :to_name => 'Paas Haas',
                :message => 'Testbericht', :node => nodes(:yet_another_page_node) }.merge(options))
  end
end
