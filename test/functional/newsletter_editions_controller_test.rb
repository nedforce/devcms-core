require File.expand_path('../../test_helper.rb', __FILE__)

class NewsletterEditionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_approved_newsletter_edition
    get :show, :id => newsletter_editions(:devcms_newsletter_edition).id
    assert_response :success
    assert assigns(:newsletter_edition)
    assert_equal nodes(:newsletter_edition_node), assigns(:node)
  end

  def test_should_not_show_unpublished_newsletter_edition
    get :show, :id => newsletter_editions(:example_newsletter_edition).id
    assert_response :not_found
  end
end
