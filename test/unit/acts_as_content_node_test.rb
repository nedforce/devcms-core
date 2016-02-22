require File.expand_path('../../test_helper.rb', __FILE__)

class ActsAsContentNodeTestTransactional < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  setup do
    @about_page = pages(:about_page)
    @arthur     = users(:arthur)
    @reader     = users(:reader)
  end

  test 'should fail save with parent for invalid parent' do
    page = build_page(parent: nodes(:devcms_news_item_node))

    assert_no_difference 'Page.count' do
      refute page.save
      assert page.errors['node.base'].any?
    end

    page = build_page(parent: nodes(:devcms_news_item_node))

    assert_no_difference 'Page.count' do
      assert_raise ActiveRecord::RecordNotSaved do
        page.save!
      end
    end
  end

  test 'should fail create with parent for invalid parent' do
    assert_no_difference 'Page.count' do
      page = Page.create(parent: nodes(:devcms_news_item_node), title: 'Page title', preamble: 'Ambule', body: 'Page body', expires_on: 1.day.from_now.to_date)
      assert page.errors['node.base'].any?
    end

    assert_no_difference 'Page.count' do
      assert_raise ActiveRecord::RecordNotSaved do
        Page.create!(parent: nodes(:devcms_news_item_node), title: 'Page title', preamble: 'Ambule', body: 'Page body', expires_on: 1.day.from_now.to_date)
      end
    end
  end

  protected

  def build_page(options = {})
    Page.new({
      parent: nodes(:root_section_node),
      title: 'Page title',
      preamble: 'Ambule',
      body: 'Page body'
    }.merge(options))
  end

  def create_page(options = {})
    page = build_page(options)
    page.save
    page
  end
end

class ActsAsContentNodeTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @about_page = pages(:about_page)
    @arthur = users(:arthur)
    @reader = users(:reader)
  end

  test 'should save with parent' do
    page = build_page(parent: nodes(:root_section_node))

    assert_difference 'Page.count', 1 do
      assert page.save
      assert_equal nodes(:root_section_node), page.node.parent
    end
  end

  test 'should fail save with parent for invalid content' do
    page = build_page body: nil

    assert_no_difference 'Page.count' do
      refute page.save
      assert page.errors[:body].any?
    end

    page = build_page body: nil

    assert_no_difference 'Page.count' do
      assert_raise ActiveRecord::RecordNotSaved do
        page.save!
      end
    end
  end

  test 'should create with parent' do
    assert_difference 'Page.count', 1 do
      assert_equal nodes(:root_section_node).reload, create_page.node.parent
    end
  end

  test 'create with parent shoudl fail for invalid content' do
    assert_no_difference 'Page.count' do
      page = create_page body: nil

      assert page.errors[:body].any?
    end
  end

  test 'create with parent should fail for nil parent' do
    assert_no_difference 'Page.count' do
      page = create_page(parent: nil)

      refute page.valid?
      assert page.new_record?
    end
  end

  test 'find accessible should only find published content nodes' do
    # Published content nodes
    [[1.day.ago, 1.day.from_now]].map do |start_date, end_date|
      page = create_page
      page.update_attributes(publication_start_date: start_date, publication_end_date: end_date)
      assert_equal page, Page.accessible.find(page.id)
    end

    # Unpublished content nodes
    [[2.days.ago, 1.day.ago], [1.day.from_now, nil], [1.day.from_now, 2.days.from_now]].map do |start_date, end_date|
      page = create_page
      node = page.node
      node.update_attribute(:publication_start_date, start_date)
      node.update_attribute(:publication_end_date, end_date)
      refute node.new_record?

      assert_raise ActiveRecord::RecordNotFound do
        Page.accessible.find page.id
      end
    end
  end

  test 'should get commentable status' do
    page = build_page
    refute page.commentable?

    page.commentable = true
    assert page.save
    assert page.commentable?
    assert page.node.commentable
  end

  test 'should set commentable to node after update' do
    page = create_page commentable: false
    refute page.commentable?
    refute page.node.commentable?

    page.commentable = true
    assert page.save(user: users(:arthur))
    assert page.commentable?
    assert page.node.commentable
  end

  test 'should return last updated at if hidden or private' do
    page = create_page

    assert_equal page.last_updated_at.to_i, page.updated_at.to_i

    page.node.hidden = true
    assert_equal page.last_updated_at.to_i, page.updated_at.to_i

    page.node.private = true
    assert_equal page.last_updated_at.to_i, page.updated_at.to_i

    page.node.hidden = false
    assert_equal page.last_updated_at.to_i, page.updated_at.to_i
  end

  test 'should set publication dates to node on save' do
    page = build_page

    assert_nil page.publication_start_date
    assert_nil page.publication_end_date

    start_date = Time.zone.now
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

  test 'publication end date should be after publication start date' do
    page = build_page

    start_date = 1.day.from_now
    end_date = Time.zone.now

    page.publication_start_date = start_date
    page.publication_end_date = end_date

    refute page.save
    refute page.valid?
    assert page.errors['node.base'].any?
  end

  test 'should set publication start date to current time after save if blank' do
    page = build_page

    assert_nil page.publication_start_date

    now = Time.zone.now
    Time.stubs(now: now)

    assert page.save

    assert_equal now, page.publication_start_date
    assert_nil page.publication_end_date
    assert_equal now, page.node.publication_start_date
    assert_nil page.node.publication_end_date
  end

  test 'should require publication start date if publication end date is present' do
    page = build_page(publication_end_date: Time.zone.now)

    refute page.save
    assert page.errors['node.base'].any?
  end

  test 'should set publication dates to node after update' do
    start_date = 1.day.from_now
    end_date = 2.days.from_now

    page = create_page publication_start_date: start_date, publication_end_date: end_date

    assert_equal start_date.to_s, page.publication_start_date.to_s
    assert_equal end_date.to_s,   page.publication_end_date.to_s

    new_start_date = 1.year.from_now
    new_end_date = 2.years.from_now

    page.publication_start_date = new_start_date
    page.publication_end_date = new_end_date

    assert page.save(user: users(:arthur))

    assert_equal new_start_date.to_s, page.publication_start_date.to_s
    assert_equal new_end_date.to_s,   page.publication_end_date.to_s
  end

  test 'should not require content box attributes' do
    page = build_page(
      content_box_title:           nil,
      content_box_icon:            nil,
      content_box_colour:          nil,
      content_box_number_of_items: nil
    )

    assert page.save, page.errors.full_messages.to_sentence
    assert page.valid?
  end

  test 'should have valid content box title length' do
    page = build_page content_box_title: 'a'

    refute page.save
    refute page.valid?
    assert page.errors['node.content_box_title'].any?

    page = build_page content_box_title: 'a' * 256

    refute page.save
    refute page.valid?
    assert page.errors['node.content_box_title'].any?
  end

  test 'should have valid content box icon' do
    page = build_page content_box_icon: 'foo'

    refute page.save
    refute page.valid?
    assert page.errors['node.content_box_icon'].any?
  end

  test 'should have valid content box color' do
    page = build_page content_box_colour: 'foo'

    refute page.save
    refute page.valid?
    assert page.errors['node.content_box_colour'].any?
  end

  test 'should have valid content box number of items' do
    page = build_page content_box_number_of_items: 1

    refute page.save
    refute page.valid?
    assert page.errors['node.base'].any?
  end

  test 'should accept empty title alternatives' do
    assert_difference 'Page.count' do
      assert_nothing_raised { create_page(title_alternative_list: '') }
    end
  end

  protected

  def build_page(options = {})
    Page.new({
      parent: nodes(:root_section_node),
      title: 'Page title',
      preamble: 'Ambule',
      body: 'Page body'
    }.merge(options))
  end

  def create_page(options = {})
    page = build_page(options)
    page.save
    page
  end
end
