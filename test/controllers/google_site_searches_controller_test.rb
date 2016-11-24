require File.expand_path('../../test_helper.rb', __FILE__)

class GoogleSiteSearchesControllerTest < ActionController::TestCase
  setup do
    Setting.where(key: 'google_search_engine').update_all(value: '123456')
  end

  test 'should get show' do
    GoogleSiteSearch::UrlBuilder.expects(:new).with(
      'test', '123456', start: 0, num: 20, filter: nil
    )
    @search = build(
      :facet_search,
      results: [stub(title: 'A title', description: 'A description', link: Faker::Internet.url, is_promotion?: false)]
    )
    GoogleSiteSearch::FacetSearch.any_instance.expects(:query).returns(@search)

    get :show, query: 'test'

    assert_response :success
  end

  test 'should get search suggestions' do
    VCR.use_cassette('google_search_suggestions') do
      get :search_suggestions, term: 'jo'
      json = JSON.parse(response.body)
      assert_includes json, 'jongeren hulp' # A 'normal' suggestion
      assert_includes json, 'Jongerenloket Deventer' # A promotion
    end
  end
end
