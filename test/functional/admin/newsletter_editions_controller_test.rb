require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::NewsletterEditionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_approved_newsletter_edition
    login_as :sjoerd
    
    get :show, :id => newsletter_editions(:devcms_newsletter_edition).id
    
    assert_response :success
    assert assigns(:newsletter_edition)
    assert_equal newsletter_editions(:devcms_newsletter_edition).node, assigns(:node)
    
  end

  
  def test_should_get_new
    login_as :sjoerd
    
    get :new, :parent_node_id => nodes(:newsletter_archive_node).id
    assert_response :success
    assert assigns(:newsletter_edition)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:newsletter_archive_node).id, :newsletter_edition => { :title => 'foo' }
    assert_response :success
    assert assigns(:newsletter_edition)
    assert_equal 'foo', assigns(:newsletter_edition).title
  end
  
  def test_should_create_newsletter_edition
    login_as :sjoerd
    
    assert_difference('NewsletterEdition.count') do
      create_newsletter_edition
      assert_response :success      
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsletterEdition.count') do
      create_newsletter_edition({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:newsletter_edition).new_record?
      assert_equal 'foobar', assigns(:newsletter_edition).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('NewsletterEdition.count') do
      create_newsletter_edition({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:newsletter_edition).new_record?
      assert assigns(:newsletter_edition).errors[:title].any?
      assert_template 'new'
    end
  end
  
  def test_should_require_title
    login_as :sjoerd
    
    assert_no_difference('NewsletterEdition.count') do
      create_newsletter_edition(:title => nil)
    end
    
    assert_response :unprocessable_entity
    assert assigns(:newsletter_edition).new_record?
    assert assigns(:newsletter_edition).errors[:title].any?
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => newsletter_editions(:devcms_newsletter_edition)
    assert_response :success
    assert assigns(:newsletter_edition)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => newsletter_editions(:devcms_newsletter_edition), :newsletter_edition => { :title => 'foo' }
    assert_response :success
    assert assigns(:newsletter_edition)
    assert_equal 'foo', assigns(:newsletter_edition).title
  end
  
  def test_should_update_newsletter_edition
    login_as :sjoerd
    
    put :update, :id => newsletter_editions(:devcms_newsletter_edition), :newsletter_edition => { :title => 'updated title', :body => 'updated body' }
    
    assert_response :success
    assert_equal 'updated title', assigns(:newsletter_edition).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    newsletter_edition = newsletter_editions(:devcms_newsletter_edition)
    old_title = newsletter_edition.title
    put :update, :id => newsletter_edition, :newsletter_edition => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:newsletter_edition).title
    assert_equal old_title, newsletter_edition.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    newsletter_edition = newsletter_editions(:devcms_newsletter_edition)
    old_title = newsletter_edition.title
    put :update, :id => newsletter_edition, :newsletter_edition => { :title => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:newsletter_edition).errors[:title].any?
    assert_equal old_title, newsletter_edition.reload.title
    assert_template 'edit'
  end
  
  def test_should_not_update_newsletter_edition
    login_as :sjoerd
    
    put :update, :id => newsletter_editions(:devcms_newsletter_edition), :newsletter_edition => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:newsletter_edition).errors[:title].any?
  end
  
  def test_should_create_newsletter_edition_with_items
    login_as :sjoerd
    
    now = Time.now + 1.hour
    post :create, :parent_node_id => nodes(:newsletter_archive_node),
                 :newsletter_edition => { :title => 'updated title', :body => 'updated body', :publication_start_date_day => now.strftime("%d-%m-%Y"), :publication_start_date_time => now.strftime("%H:%M") }, 
                 :items => [ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id ]

    assert_response :success    
    assert_equal 3, assigns(:newsletter_edition).items.size
  end  
  
  def test_should_add_items_to_newsletter_edition
    login_as :sjoerd
    
    put :update, :id => newsletter_editions(:devcms_newsletter_edition),
                 :newsletter_edition => { :title => 'updated title', :body => 'updated body' }, 
                 :items => [ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id ]
    
    assert_response :success
    assert_equal 'updated title', assigns(:newsletter_edition).title
    assert_equal 3, assigns(:newsletter_edition).items.size
  end
  
  def test_should_set_publication_start_date_on_create
    login_as :sjoerd

    assert_difference('NewsletterEdition.count') do
      date = 1.year.from_now
      create_newsletter_edition :publication_start_date => date
      assert_response :success
      assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:newsletter_edition).publication_start_date
    end
  end

  def test_should_set_publication_start_date_on_update
    login_as :sjoerd

    date = 1.year.from_now

    put :update, :id => newsletter_editions(:devcms_newsletter_edition),
                 :newsletter_edition => { :publication_start_date_day => date.strftime("%d-%m-%Y"), :publication_start_date_time => date.strftime("%H:%M") }

    assert_response :success
    assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:newsletter_edition).publication_start_date
  end

protected
  
  def create_newsletter_edition(attributes = {}, options = {})
    publication_start_date = attributes.delete(:publication_start_date) || Time.now
    post :create, { :parent_node_id => nodes(:newsletter_archive_node).id, :newsletter_edition => { :title => 'new title', :body => 'Lorem ipsum', :publication_start_date_day => publication_start_date.strftime("%d-%m-%Y"), :publication_start_date_time => publication_start_date.strftime("%H:%M") }.merge(attributes), :items => [ nodes(:help_page_node).id ]}.merge(options)
  end
end
