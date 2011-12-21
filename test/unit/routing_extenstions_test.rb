require File.dirname(__FILE__) + '/../test_helper'

class RoutingExtensionsTest < ActionController::TestCase

  def setup
    @help_page = pages(:help_page)
    @about_page = pages(:about_page)
    @help_page_node = nodes(:help_page_node)
    @about_page_node = nodes(:about_page_node)
    @devcms_news = news_archives(:devcms_news)
    @test_image = images(:test_image)
    @test_image_node = nodes(:test_image_node)
    @test_image_copy_node = nodes(:test_image_copy_node)
    @section_with_frontpage_node = nodes(:section_with_frontpage_node)
    @frontpage_for_section = pages(:frontpage_for_section)
    @frontpage_for_section_node = nodes(:frontpage_for_section_node)
    @root_section = sections(:root_section)
    @root_section_node = nodes(:root_section_node)
    @economie_section = sections(:economie_section)
    @economie_section_node = nodes(:economie_section_node)
    @sub_site_section = sections(:sub_site_section)
    @sub_site_section_node = nodes(:sub_site_section_node)
  end

  def test_should_not_delegate_or_unalias_for_non_delegated_or_url_aliased_routes
    assert_recognizes({ :controller => 'sessions', :action => 'new', :site_id => @root_section_node.id }, "/login")
    assert_recognizes({ :controller => 'users', :action => 'new', :site_id => @root_section_node.id }, "/users/new")
  end

  def test_should_delegate_for_delegated_routes
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => @help_page.id, :node_id => @help_page_node.id, :site_id => @root_section_node.id }, "/content/#{@help_page_node.id}" )
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id }, "/content/#{@about_page_node.id}" )
  end

  def test_should_pass_path_parameters_on_delegation
    assert_recognizes({ :controller => 'pages', :action => 'edit', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id }, "/content/#{@about_page_node.id}/edit" )
  end

  def test_should_pass_query_parameters_on_delegation
    assert_recognizes({ :controller => 'pages', :action => 'edit', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/content/#{@about_page_node.id}/edit", { :foo => 'bar', :baz => 'quux' } )
  end

  def test_should_delegate_for_content_copies
    assert_recognizes({ :controller => 'images', :action => 'edit', :id => @test_image.id, :node_id => @test_image_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/content/#{@test_image_copy_node.id}/edit", { :foo => 'bar', :baz => 'quux' } )
  end

  def test_should_delegate_for_sections_with_frontpages_set
    assert_recognizes({ :controller => 'pages', :action => 'edit', :id => @frontpage_for_section.id, :node_id => @frontpage_for_section_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/content/#{@section_with_frontpage_node.id}/edit", { :foo => 'bar', :baz => 'quux' } )
  end

  def test_should_not_delegate_for_sections_without_frontpages_set
    assert_recognizes({ :controller => 'sections', :action => 'edit', :id => @economie_section.id, :node_id => @economie_section_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/content/#{@economie_section_node.id}/edit", { :foo => 'bar', :baz => 'quux' } )
  end

  def test_should_raise_exception_for_unrecognized_delegated_route
    assert_nothing_raised do
      assert_recognizes({ :controller => 'errors', :action => "error_404", :site_id => @root_section_node.id }, "/content_nodes/-1" )
    end

    assert_nothing_raised do
      assert_recognizes({ :controller => 'errors', :action => "error_404", :site_id => @root_section_node.id }, "/content_nodes/foo" )
    end

    assert_nothing_raised do
      assert_recognizes({ :controller => 'errors', :action => "error_404", :site_id => @root_section_node.id }, "/content_nodes" )
    end
    
    assert_nothing_raised do
      assert_recognizes({ :controller => 'errors', :action => "error_404", :site_id => @root_section_node.id }, "/images/forum.php?hackery=true" )
    end
    
    assert_nothing_raised do
      assert_recognizes({ :controller => 'errors', :action => "error_404", :site_id => @root_section_node.id }, "/pages/../../../configuration.php" )
    end
  end

  def test_should_unalias_for_url_aliased_routes
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => @help_page.id, :node_id => @help_page_node.id, :site_id => @root_section_node.id }, "/#{@help_page_node.url_alias}" )
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id }, "/#{@about_page_node.url_alias}" )
    assert_recognizes({ :controller => 'pages', :action => 'edit', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id }, "/#{@about_page_node.url_alias}/edit" )
  end

  def test_should_pass_path_parameters_on_unaliasing
    assert_recognizes({ :controller => 'pages', :action => 'edit', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id }, "/#{@about_page_node.url_alias}/edit" )
  end

  def test_should_pass_query_parameters_on_unaliasing
    assert_recognizes({ :controller => 'pages', :action => 'edit', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/#{@about_page_node.url_alias}/edit", { :foo => 'bar', :baz => 'quux' } )
  end

  def test_should_unalias_for_content_copies
    @test_image_copy_node.send(:set_url_alias)
    @test_image_copy_node.save!
    assert_recognizes({ :controller => 'images', :action => 'edit', :id => @test_image.id, :node_id => @test_image_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/#{@test_image_copy_node.url_alias}/edit", { :foo => 'bar', :baz => 'quux' } )
  end

  def test_should_unalias_and_delegate_for_sections_with_frontpages_set
    @section_with_frontpage_node.send(:set_url_alias)
    @section_with_frontpage_node.save!
    assert_recognizes({ :controller => 'pages', :action => 'edit', :id => @frontpage_for_section.id, :node_id => @frontpage_for_section_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/#{@section_with_frontpage_node.url_alias}/edit", { :foo => 'bar', :baz => 'quux' } )
  end

  def test_should_unalias_and_not_delegate_for_sections_without_frontpages_set
    @root_section_node.send(:set_url_alias)
    @root_section_node.save!
    assert_recognizes({ :controller => 'sections', :action => 'edit', :id => @economie_section.id, :node_id => @economie_section_node.id, :site_id => @root_section_node.id, :foo => 'bar', :baz => 'quux' }, "/#{@economie_section_node.url_alias}/edit", { :foo => 'bar', :baz => 'quux' } )
  end
  
  def  test_should_unalias_and_delegate_for_sections_with_frontpages_set_to_content_copy
    @root_section_node.send(:set_url_alias)
    @root_section_node.save!
    @root_section_node.reload
    @root_section_node.content.update_attributes :frontpage_node_id => nodes(:bewoners_forum_copy_node).id
    assert_nothing_raised do
      assert_recognizes({ :controller => 'forums', :action => 'show', :id => forums(:bewoners_forum).id, :node_id => nodes(:bewoners_forum_node).id, :site_id => @root_section_node.id }, "/#{@section_with_frontpage_node.url_alias}")
    end
  end
  
  def  test_should_unalias_and_delegate_for_content_copies_to_section_with_frontpage
    @section_with_frontpage_node.send(:set_url_alias)
    @section_with_frontpage_node.save!
    @section_with_frontpage_node.reload
    @copy = ContentCopy.create!(:copied_node => @section_with_frontpage_node, :parent => Node.root)
    assert_nothing_raised do
      assert_recognizes({ :controller => 'pages', :action => 'show', :id => @frontpage_for_section_node.content.id, :node_id => @frontpage_for_section_node.id, :site_id => @root_section_node.id }, "/#{@copy.node.url_alias}")
    end
  end

  def test_should_raise_exception_for_unrecognized_url_aliased_route
    assert_nothing_raised do
      assert_recognizes({ :controller => 'errors', :action => "error_404", :site_id => @root_section_node.id }, "/_non_existant_alias" )
    end
  end

  def test_should_delegate_root_without_frontpage_node
    @root_section.update_attributes(:frontpage_node => nil)
    assert_recognizes({ :controller => 'sections', :action => 'show', :id => @root_section.id, :node_id => @root_section_node.id, :site_id => @root_section_node.id }, "/" )
  end

  def test_should_delegate_root_with_frontpage_node
    @root_section.update_attributes(:frontpage_node => @about_page_node)
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => @about_page.id, :node_id => @about_page_node.id, :site_id => @root_section_node.id }, "/" )
  end

  def test_should_raise_exception_for_invalid_delegated_root
    assert_nothing_raised do
      assert_recognizes({ :controller => 'errors', :action => "error_404", :site_id => @root_section_node.id }, "/this_url_should_never_exist_so_dont_add_it_to_the_fixtures" )
    end
  end

  # Subsite testing

  def test_should_lookup_site_by_host
    assert_recognizes({ :controller => 'sections', :action => 'show', :id => @sub_site_section.id, :node_id => @sub_site_section_node.id, :site_id => @sub_site_section_node.id }, "/" , :host => 'test.local.dev')
  end
  
  def test_should_drop_www_for_domain_lookup
    assert_recognizes({ :controller => 'sections', :action => 'show', :id => @sub_site_section.id, :node_id => @sub_site_section_node.id, :site_id => @sub_site_section_node.id }, "/" , :host => 'www.test.local.dev')
  end
  
  def test_should_set_site_id
    assert_recognizes({ :controller => 'pages', :action => 'show', :id => pages(:yet_another_page).id, :node_id => nodes(:yet_another_page_node).id, :site_id => @sub_site_section_node.id }, "/content/#{nodes(:yet_another_page_node).id}", :host => 'test.local.dev' )
  end
  
  

  protected

    # Override these methods to support host-setting on the test request
    def assert_recognizes(expected_options, path, extras = {}, message = nil)
      if path.is_a? Hash
        request_method = path[:method]
        path           = path[:path]
      else
        request_method = nil
      end

      clean_backtrace do
        ActionController::Routing::Routes.reload if ActionController::Routing::Routes.empty?

        request_options = {}
        request_options[:host] = extras.delete(:host) if extras.has_key?(:host)
        request = recognized_request_for(path, request_method, request_options)

        expected_options = expected_options.clone
        extras.each_key { |key| expected_options.delete key } unless extras.nil?

        options = {}
        expected_options.each {|k,v| options[k.to_s]=v.to_s}
        routing_diff = options.diff(request.path_parameters)
        msg = build_message(message, "The recognized options <?> did not match <?>, difference: <?>", request.path_parameters, options, options.diff(request.path_parameters))
        assert_block(msg) { request.path_parameters == options }
      end
    end

  private
    # Recognizes the route for a given path.
    def recognized_request_for(path, request_method = nil, request_options = {})
      path = "/#{path}" unless path.first == '/'

      # Assume given controller
      request = ActionController::TestRequest.new
      request.host = request_options[:host] if request_options.has_key?(:host)
      request.env["REQUEST_METHOD"] = request_method.to_s.upcase if request_method
      request.path   = path

      ActionController::Routing::Routes.recognize(request)
      request
    end

end