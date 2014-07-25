require File.expand_path('../../test_helper.rb', __FILE__)

class SearchControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  @@index_built = false

  setup do
    # unless @@index_built
    #   Node.rebuild_index
    #   Synonym.rebuild_index
    #   @@index_built = true
    # end
    Node.stubs(:find_with_ferret).returns(stub({
      :total_hits => 0
    }))
    Search::FerretSearch.stubs(:create_search_string).returns("query")
    # Search::FerretSearch.stubs(:expand_query).returns("expanded query")
  end

  def test_should_search_on_post
    post :index, :query => 'forum'
    assert_response :success
    assert assigns(:results)
  end

  def test_should_search_on_post_for_invalid_search_scope
    post :index, :query => 'forum', :search_scope => 'sajdljsaldsa'
    assert_response :success
    assert assigns(:results)
  end

  def test_should_search_on_get
    get :index, :query => 'forum'
    assert_response :success
    assert assigns(:results)
  end

  def test_should_not_scope_within_top_node_for_root_node
    root_node = nodes(:root_section_node)
    descendant_section_node = nodes(:bis_section_node)

    Search::FerretSearch.expects(:paginating_ferret_search).with do |args|
      (args[:q] =~ /ancestry_to_index:XX#{root_node.child_ancestry.gsub(/\//, 'X')}X*/).nil?
    end

    post :index, :query => 'blaat', :search_scope => "node_#{root_node.id}"
  end

  def test_should_scope_within_top_node_for_descendant_node
    descendant_section_node = nodes(:bis_section_node)

    Search::FerretSearch.expects(:paginating_ferret_search).with do |args|
      args[:q] =~ /ancestry_to_index:XX#{descendant_section_node.child_ancestry.gsub(/\//, 'X')}X*/
    end

    post :index, :query => 'blaat', :search_scope => "node_#{descendant_section_node.id}"
  end

protected

  def create_page(attributes = {}, options = {})
    parent_node = options.delete(:parent_node) || nodes(:root_section_node)
    Page.create({ :parent => parent_node, :title => 'Page title', :preamble => 'Ambule', :body => 'Page body' }.merge(options))
  end

end

