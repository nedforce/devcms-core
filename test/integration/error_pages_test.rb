require File.expand_path('../../test_helper.rb', __FILE__)

# This test might not work when running all tests using 'rake test' due to the
# fact that the exceptions middleware is not properly initialized in that case.
class ErrorPagesTest < ActionDispatch::IntegrationTest
  fixtures :nodes, :pages

  test 'should render custom 404' do
    Settler.error_page_404.update_attribute(:value, nodes(:help_page_node).url_alias)

    get '/this/page/does/not/exist'
    assert_response :not_found
    assert assigns(:page).node.url_alias, nodes(:help_page_node).url_alias
  end

  test 'should render default template if no custom page is set' do
    Settler.error_page_404.update_attribute(:value, nil)

    get '/this/page/does/not/exist'
    assert_response :not_found
    assert_template 'errors/404'
  end

  test 'should render default template if custom page is not found' do
    Settler.error_page_404.update_attribute(:value, 'this/custom/error/page/does/not/exist')

    get '/this/page/does/not/exist'
    assert_response :not_found
    assert_template 'errors/404'
  end
end
