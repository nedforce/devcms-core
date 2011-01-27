require File.dirname(__FILE__) + '/../test_helper'

class SharesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_new
    get :new, :node_id => nodes(:yet_another_page_node).id
    assert assigns(:share)
    assert_response :success
  end

  def test_should_create_share
    assert_difference 'ActionMailer::Base.deliveries.size' do
      create_share
    end
    assert assigns(:node)
    assert_response :redirect
  end

  def test_should_not_create_share
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      create_share(:from_email_address => nil)
    end
    assert assigns(:node)
    assert_response :success
  end

  protected

  def create_share(options = {})
    post :create, :node_id => nodes(:yet_another_page_node).id, :share =>
                    { :from_email_address => 'test@nedforce.nl', :from_name => 'Nedforce test',
                    :to_email_address => 'paas@haas.nl', :to_name => 'Paas Haas',
                    :message => 'Testbericht' }.merge(options)
  end
end
