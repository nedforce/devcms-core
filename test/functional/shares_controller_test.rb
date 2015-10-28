require File.expand_path('../../test_helper.rb', __FILE__)

class SharesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should get new' do
    get :new, node_id: nodes(:yet_another_page_node).id
    assert assigns(:share)
    assert_response :success
  end

  test 'should create share' do
    assert_difference 'ActionMailer::Base.deliveries.size' do
      create_share
    end
    assert assigns(:node)
    assert_response :redirect
  end

  test 'should not create share' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      create_share(from_email_address: nil)
    end
    assert assigns(:node)
    assert_response :success
  end

  protected

  def create_share(options = {})
    post :create, node_id: nodes(:yet_another_page_node).id, share: {
      from_email_address: 'test@nedforce.nl', from_name: 'Nedforce test',
      to_email_address: 'paas@haas.nl', to_name: 'Paas Haas',
      message: 'Testbericht'
    }.merge(options)
  end
end
