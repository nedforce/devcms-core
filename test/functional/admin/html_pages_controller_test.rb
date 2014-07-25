require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::HtmlPagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @html_page = html_pages(:about_html_page)
  end

  def test_should_get_show
    login_as :arthur

    get :show, :id => @html_page
    assert_response :success
    assert assigns(:html_page)
  end

  def test_should_get_new
    login_as :arthur

    get :new, :parent_node_id => nodes(:root_section_node)
    assert_response :success
    assert assigns(:html_page)
  end

  def test_should_get_new_with_params
    login_as :arthur

    get :new, :parent_node_id => nodes(:root_section_node).id, :html_page => { :title => 'foo' }
    assert_response :success
    assert assigns(:html_page)
    assert_equal 'foo', assigns(:html_page).title
  end

  def test_should_create_html_page
    login_as :arthur

    assert_difference('HtmlPage.count') do
      create_html_page
      assert_response :success
      assert !assigns(:html_page).new_record?, assigns(:html_page).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :arthur

    assert_no_difference('HtmlPage.count') do
      create_html_page({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:html_page).new_record?
      assert_equal 'foobar', assigns(:html_page).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :arthur

    assert_no_difference('HtmlPage.count') do
      create_html_page({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:html_page).new_record?
      assert assigns(:html_page).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :arthur

    assert_no_difference('HtmlPage.count') do
      create_html_page({ :title => nil })
    end
    assert_response :unprocessable_entity
    assert assigns(:html_page).new_record?
    assert assigns(:html_page).errors[:title].any?
  end

  def test_should_get_edit
    login_as :arthur

    get :edit, :id => @html_page
    assert_response :success
    assert assigns(:html_page)
  end

  def test_should_get_edit_with_params
    login_as :arthur

    get :edit, :id => @html_page, :html_page => { :title => 'foo' }
    assert_response :success
    assert assigns(:html_page)
    assert_equal 'foo', assigns(:html_page).title
  end

  def test_should_update_html_page
    login_as :arthur

    put :update, :id => @html_page, :html_page => {:title => 'updated title', :body => 'updated_body'}

    assert_response :success
    assert_equal 'updated title', assigns(:html_page).title
  end

  def test_should_get_valid_preview_for_update
    login_as :arthur

    html_page = @html_page
    old_title = html_page.title
    put :update, :id => html_page.id, :html_page => {:title => 'updated title', :body => 'updated_body'}, :commit_type => 'preview'
    assert_response :success
    assert_equal 'updated title', assigns(:html_page).title
    assert_equal old_title, html_page.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :arthur

    html_page = @html_page
    old_title = html_page.title
    put :update, :id => html_page.id, :html_page => {:title => nil, :body => 'updated_body'}, :commit_type => 'preview'
    assert_response :unprocessable_entity
    assert assigns(:html_page).errors[:title].any?
    assert_equal old_title, html_page.reload.title
    assert_template 'edit'
  end

protected

  def create_html_page(attributes = {}, options = {})
    post :create, {:parent_node_id => nodes(:root_section_node).id, :html_page => { :title => 'new title', :body => 'Lorem ipsum' }.merge(attributes)}.merge(options)
  end

end
