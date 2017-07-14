require File.expand_path('../../test_helper.rb', __FILE__)

class PandoSearchControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    Devcms.stubs(:search_configuration).returns(
      enabled_search_engines: ['pando_search'],
      default_search_engine: 'pando_search',
      default_page_size: 5
    )
    DevcmsCore.config.pando_suggest_url = 'https://search.enrise.com/deventer.nl/suggest'
  end

  test 'should get search suggestions' do
    VCR.use_cassette('search_suggest') do
      get 'search_suggestions', :term => 'for'
    end

    assert_response :success
    assert_equal response.content_type, "application/json"
    assert JSON.parse(response.body).is_a?(Array)
  end

end
