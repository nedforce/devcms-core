require File.expand_path('../../test_helper.rb', __FILE__)

class SearchControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  @@index_built = false

  def setup
    unless @@index_built 
      `rm -rf #{File.join(Rails.root, 'index')}`
      Node.rebuild_index
      @@index_built = true
    end
  end

  def test_should_search_on_post
    post :index, :query => 'forum'
    assert_response :success
    assert assigns(:results)
    assert assigns(:results).size > 0
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
    assert assigns(:results).size > 0
  end

  def test_should_fuzzy_search
    Search::FerretSearch.stubs(:ferret_configuration).returns({ :synonym_weight => 0.25, :proximity => 0.5 })
    post :index, :query => 'vorum'
    assert_response :success
    assert assigns(:results)
    assert assigns(:results).size > 0
  end

  def test_should_allow_wildcard_searches
    post :index, :query => 'for*'
    assert_response :success
    assert assigns(:results)
    assert assigns(:results).size > 0
  end

  def test_should_get_empty_search
    post :index, :query => 'ditbestaatzekerwetenniet'
    assert_response :success
    assert assigns(:results)
    assert assigns(:results).size == 0
  end

  def test_should_find_page_in_private_section
    nodes(:not_hidden_section_node).update_attribute(:private, true)
    
    login_as :reader
    post :index, :query => 'koffiemokkenverzamelaar', :search_scope => "node_#{nodes(:not_hidden_section_node).id}"

    assert assigns(:private_menu_items).include?(nodes(:not_hidden_section_node))
    assert_response :success
    assert_not_nil assigns(:results)
    assert_equal nodes(:not_hidden_section_node), assigns(:top_node), "Top node should remain the same!"
  end

  def test_should_search_in_bis
    login_as :reader
    post :index, :query => 'bestuursinformatie', :search_scope => "node_#{nodes(:bis_section_node).id}"
    assert_response :success
    assert_not_nil assigns(:results)
    assert_equal nodes(:bis_section_node), assigns(:top_node), "Top node should remain the same!"
  end

  def test_should_allow_or_operator
    login_as :reader
    post :index, :query => 'forum OR ditbestaatzekerniet'
    assert_response :success
    assert assigns(:results)
    assert assigns(:results).size > 0
  end

  def test_should_allow_and_operator
    login_as :reader
    post :index, :query => 'forum AND ditbestaatzekerniet'
    assert_response :success
    assert assigns(:results)
    assert assigns(:results).size == 0
  end

  def test_should_allow_not_operator
    login_as :reader

    post :index, :query => 'foru* NOT bestuursinformatie'
    assert_response :success
    assert assigns(:results)
    assert assigns(:results).size > 0
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
    Page.create({:parent => parent_node, :title => "Page title", :preamble => "Ambule", :body => "Page body" }.merge(options))
  end

end

