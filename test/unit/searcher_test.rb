require File.expand_path('../../test_helper.rb', __FILE__)

class SearcherTest < ActiveSupport::TestCase

  require 'rsolr'

  def setup
    Devcms.stubs(:search_configuration).returns(
      {
        :enabled_search_engines => [ 'ferret' ], 
        :default_search_engine => 'ferret',
        :default_page_size => 5,        
        :ferret => {
          :synonym_weight => 0.25,
          :proximity => 0.8
        }
      })     
  end

  def test_should_use_default_engine  
    assert_equal Search::FerretSearch, Searcher.new.engine
    
    new_config = Devcms.search_configuration.merge({ :default_search_engine => 'ferret' })
    Devcms.expects(:search_configuration).at_least(1).returns(new_config)        
    assert_equal Search::FerretSearch, Searcher.new.engine
  end

  def test_should_not_accept_non_existing_engine
    assert_raise RuntimeError do
      Searcher(:fail)
    end
  end

  def test_should_search          
    RSolr::Client.any_instance.expects(:select).returns({})
    Search::FerretSearch.expects(:search).returns({})

    assert_not_nil Searcher(:ferret).search('test')
  end

end

