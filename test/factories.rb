FactoryGirl.define do
  factory :facet_search, class: 'GoogleSiteSearch::FacetSearch' do
    initialize_with { new('test', 'test')  }
    transient do
      estimated_results_total 10
      previous_results_url Faker::Internet.url
      next_results_url Faker::Internet.url
      results []
      facets []
    end

    after(:build) do |model, evaluator|
      model.instance_variable_set(:@estimated_results_total, evaluator.estimated_results_total)
      model.instance_variable_set(:@previous_results_url, evaluator.previous_results_url)
      model.instance_variable_set(:@next_results_url, evaluator.next_results_url)
      model.instance_variable_set(:@results, evaluator.results)
      model.instance_variable_set(:@facets, evaluator.facets)
    end
  end
end
