require File.expand_path('../../test_helper.rb', __FILE__)

class ShareTest < ActiveSupport::TestCase
  test 'should create valid share' do
    # We cannot assert_difference on the model, because share is not really an ActiveRecord model.
    share = create_share
    assert share.valid?
  end

  test 'should require from email address' do
    share = create_share(from_email_address: nil)
    assert !share.valid?
  end

  test 'should require from name' do
    share = create_share(from_name: nil)
    assert !share.valid?
  end

  test 'should require to email address' do
    share = create_share(to_email_address: nil)
    assert !share.valid?
  end

  test 'should require to name' do
    share = create_share(to_name: nil)
    assert !share.valid?
  end

  test 'should require message' do
    share = create_share(message: nil)
    assert !share.valid?
  end

  test 'should require node' do
    share = create_share(node: nil)
    assert !share.valid?
  end

  test 'should return subject' do
    share = create_share
    assert_equal share.subject, 'Yet'
  end

  test 'should send recommendation email' do
    share = create_share
    assert_difference 'ActionMailer::Base.deliveries.size' do
      share.send_recommendation_email
    end
  end

  protected

  def create_share(options = {})
    Share.new({
      from_email_address: 'test@nedforce.nl',
      from_name:          'Nedforce test',
      to_email_address:   'paas@haas.nl',
      to_name:            'Paas Haas',
      message:            'Testbericht',
      node:               nodes(:yet_another_page_node)
    }.merge(options))
  end
end
