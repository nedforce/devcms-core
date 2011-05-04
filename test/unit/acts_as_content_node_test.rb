require File.dirname(__FILE__) + '/../test_helper'

class ActsAsContentNodeTestTransactional < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  
  def setup
    @about_page = pages(:about_page)
    @arthur = users(:arthur)
    @reader = users(:reader)
  end
  
  def test_save_with_parent_should_fail_for_invalid_parent
    page = build_page(:parent => nodes(:henk_weblog_post_one_node))
    
    assert_no_difference 'Page.count' do
      assert !page.save
      assert page.errors.on_base
    end

    page = build_page(:parent => nodes(:henk_weblog_post_one_node))

    assert_no_difference 'Page.count' do
      assert_raise ActiveRecord::RecordInvalid do
        page.save!
      end
    end
  end
   
  def test_create_with_parent_should_fail_for_invalid_parent
    assert_no_difference 'Page.count' do
      page = Page.create(:parent => nodes(:henk_weblog_post_one_node), :title => "Page title", :preamble => "Ambule", :body => "Page body")
      assert page.errors.on_base
    end

    assert_no_difference 'Page.count' do
      assert_raise ActiveRecord::RecordInvalid do
        Page.create!(:parent => nodes(:henk_weblog_post_one_node), :title => "Page title", :preamble => "Ambule", :body => "Page body")
      end
    end
  end
  
  protected

    def build_page(options = {})
      Page.new({ :parent => nodes(:root_section_node), :title => "Page title", :preamble => "Ambule", :body => "Page body" }.merge(options))
    end

    def create_page(options = {})
      page = build_page(options)
      page.save
      page
    end
  
end

class ActsAsContentNodeTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @about_page = pages(:about_page)
    @arthur = users(:arthur)
    @reader = users(:reader)
  end

  def test_should_respond_to_find_accessible
    assert Page.respond_to?(:find_accessible)
  end

  def test_save_with_parent
    page = build_page(:parent => nodes(:root_section_node))

    assert_difference 'Page.count', 1 do
      assert page.save
      assert_equal nodes(:root_section_node), page.node.parent
    end
  end

  def test_save_with_parent_should_fail_for_invalid_content
    page = build_page :body => nil

    assert_no_difference 'Page.count' do
      assert !page.save
      assert page.errors.on(:body)
    end

    page = build_page :body => nil

    assert_no_difference 'Page.count' do
      assert_raise ActiveRecord::RecordInvalid do
        page.save!
      end
    end
  end

  def test_create_with_parent
    assert_difference 'Page.count', 1 do
      assert_equal nodes(:root_section_node).reload, create_page.node.parent
    end
  end

  def test_create_with_parent_should_fail_for_invalid_content
    assert_no_difference 'Page.count' do
      page = create_page :body => nil
      assert page.errors.on(:body)
    end
  end

  def test_create_with_parent_should_fail_for_nil_parent
    assert_no_difference 'Page.count' do
      p = create_page(:parent => nil)
      assert !p.valid?
      assert p.new_record?
    end
  end

  
  def test_find_accessible_should_only_find_published_content_nodes
    # Published content nodes
    [ [ nil, nil ], [ 1.day.ago, nil ], [ 1.day.ago, 1.day.from_now ] ].map do | start_date, end_date |
      page = create_page
      node = page.node
      node.update_attribute(:publication_start_date, start_date)
      node.update_attribute(:publication_end_date, end_date)
      assert !node.new_record?
      assert_equal page, Page.find_accessible(page.id)
    end

    # Unpublished content nodes
    [ [ 2.days.ago, 1.day.ago ], [ 1.day.from_now, nil ], [ 1.day.from_now, 2.days.from_now ] ].map do | start_date, end_date |
      page = create_page
      node = page.node
      node.update_attribute(:publication_start_date, start_date)
      node.update_attribute(:publication_end_date, end_date)
      assert !node.new_record?

      assert_raise ActiveRecord::RecordNotFound do
        Page.find_accessible page.id
      end
    end
  end

  def test_should_get_commentable_status
    page = build_page
    assert !page.commentable?

    page.commentable = true
    assert page.save
    assert page.commentable?
    assert page.node.commentable
  end

  def test_should_set_publication_dates_to_node_on_save
    page = build_page

    assert_nil page.publication_start_date
    assert_nil page.publication_end_date

    start_date = Time.now
    end_date = 1.day.from_now

    page.publication_start_date = start_date
    page.publication_end_date = end_date

    assert_equal start_date.to_s, page.publication_start_date.to_s
    assert_equal end_date.to_s, page.publication_end_date.to_s

    assert page.save

    assert_equal start_date.to_s, page.publication_start_date.to_s
    assert_equal end_date.to_s, page.publication_end_date.to_s
    assert_equal start_date.to_s, page.node.publication_start_date.to_s
    assert_equal end_date.to_s, page.node.publication_end_date.to_s
  end

  def test_publication_end_date_should_be_after_publication_start_date
    page = build_page

    start_date = 1.day.from_now
    end_date = Time.now

    page.publication_start_date = start_date
    page.publication_end_date = end_date

    assert !page.save
    assert !page.valid?
    assert page.errors.on_base
  end

  def test_publication_start_date_should_be_set_to_current_time_after_save_if_blank
    page = build_page

    assert_nil page.publication_start_date

    now = Time.now
    Time.stubs(:now => now)

    assert page.save
    
    assert_equal now, page.publication_start_date
    assert_nil page.publication_end_date
    assert_equal now, page.node.publication_start_date
    assert_nil page.node.publication_end_date
  end

  def test_publication_start_date_should_be_required_if_publication_end_date_is_present
    page = build_page(:publication_end_date => Time.now)
    assert !page.save
    assert page.errors.on_base
  end

  def test_should_set_commentable_to_node_after_update
    page = create_page :commentable => false
    assert !page.commentable?
    assert !page.node.commentable?

    page.commentable = true
    assert page.save_for_user(users(:arthur))
    assert page.commentable?
    assert page.node.commentable
  end

  def test_should_set_publication_dates_to_node_after_update
    start_date = 1.day.from_now
    end_date = 2.days.from_now

    page = create_page :publication_start_date => start_date, :publication_end_date => end_date

    assert_equal start_date.to_s, page.publication_start_date.to_s
    assert_equal end_date.to_s, page.publication_end_date.to_s

    new_start_date = 1.year.from_now
    new_end_date = 2.years.from_now

    page.publication_start_date = new_start_date
    page.publication_end_date = new_end_date

    assert page.save_for_user(users(:arthur))

    assert_equal new_start_date.to_s, page.publication_start_date.to_s
    assert_equal new_end_date.to_s, page.publication_end_date.to_s
  end

  def test_content_box_attributes_should_not_be_required
    page = build_page :content_box_title => nil, :content_box_icon => nil,
                      :content_box_colour => nil, :content_box_number_of_items => nil

    assert page.save
    assert page.valid?
  end

  def test_content_box_title_should_have_a_valid_length
    page = build_page :content_box_title => 'a'

    assert !page.save
    assert !page.valid?
    assert page.errors.on(:content_box_title)

    page = build_page :content_box_title => 'a' * 256

    assert !page.save
    assert !page.valid?
    assert page.errors.on(:content_box_title)
  end

  def test_content_box_icon_should_be_valid
    page = build_page :content_box_icon => 'foo'
    assert !page.save
    assert !page.valid?
    assert page.errors.on(:content_box_icon)
  end

  def test_content_box_colour_should_be_valid
    page = build_page :content_box_colour => 'foo'
    assert !page.save
    assert !page.valid?
    assert page.errors.on(:content_box_colour)
  end

  def test_content_box_number_of_items_should_be_valid
    page = build_page :content_box_number_of_items => 1
    assert !page.save
    assert !page.valid?
    assert page.errors.on_base
  end

  def test_should_save_categories_to_node_while_keeping_existing_categories
    category1 = Category.create(:name => 'Categorie 1')
    category2 = Category.create(:name => 'Categorie 2')

    page = create_page(:category_ids => [ category1.id, category2.id ], :keep_existing_categories => true)

    assert page.categories.include?(category1)
    assert page.categories.include?(category2)
    assert page.node.categories.include?(category1)
    assert page.node.categories.include?(category2)

    category3 = Category.create(:name => 'Categorie 3')

    assert page.update_attributes(:category_ids => [ category2.id, category3.id ], :keep_existing_categories => true)

    assert page.categories.include?(category2)
    assert page.categories.include?(category3)
    assert page.node.categories.include?(category1)
    assert page.node.categories.include?(category2)
    assert page.node.categories.include?(category3)
  end

  def test_should_save_categories_to_node_without_keeping_existing_categories
    category1 = Category.create(:name => 'Categorie 1')
    category2 = Category.create(:name => 'Categorie 2')

    page = create_page(:category_ids => [ category1.id, category2.id ], :keep_existing_categories => false)

    assert page.categories.include?(category1)
    assert page.categories.include?(category2)
    assert page.node.categories.include?(category1)
    assert page.node.categories.include?(category2)

    category3 = Category.create(:name => 'Categorie 3')

    assert page.update_attributes(:category_ids => [ category2.id, category3.id ], :keep_existing_categories => false)

    assert page.categories.include?(category2)
    assert page.categories.include?(category3)
    assert !page.node.categories.include?(category1)
    assert page.node.categories.include?(category2)
    assert page.node.categories.include?(category3)
  end

  def test_should_save_category_attributes_to_node_associated_categories_on_save
    category1 = Category.create(:name => 'Categorie 1')
    category2 = Category.create(:name => 'Categorie 2')

    page = create_page(:category_ids => [ category1.id, category2.id ])

    page.update_attributes(:category_attributes => {
      category1.id => { :synonyms => 'Categorie 1' },
      category2.id => { :synonyms => 'Categorie 2' },
    })

    assert_equal 'Categorie 1', category1.reload.synonyms
    assert_equal 'Categorie 2', category2.reload.synonyms
  end
  
protected

  def build_page(options = {})
    Page.new({ :parent => nodes(:root_section_node), :title => "Page title", :preamble => "Ambule", :body => "Page body" }.merge(options))
  end

  def create_page(options = {})
    page = build_page(options)
    page.save
    page
  end

end

