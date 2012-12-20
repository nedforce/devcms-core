require File.expand_path('../../test_helper.rb', __FILE__)

class NodeTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @arthur                = users(:arthur)
    @editor                = users(:editor)
    @root_node             = nodes(:root_section_node)
    @root_section          = sections(:root_section)
    @about_page_node       = nodes(:about_page_node)
    @help_page_node        = nodes(:help_page_node)
    @contact_page_node     = nodes(:contact_page_node)
    @economie_section_node = nodes(:economie_section_node)
    @economie_section      = sections(:economie_section)
    @header_img_data       = fixture_file_upload('files/test.jpg')
  end

  def test_node_should_still_exist_after_reload
    node = create_page.node
    assert node.reload
  end

  def test_node_should_be_updateable
    node = create_page.node
    date = Time.now

    assert node.update_attributes(:publication_start_date => date)
    assert_equal date, node.publication_start_date
  end

  def test_root_node_should_be_updateable
    node = @root_node
    date = Time.now

    assert node.update_attributes(:publication_start_date => date)
    assert_equal date, node.publication_start_date
  end

  def test_should_create_node
    assert_difference 'Node.count' do
      cn = create_page
      assert_equal 'foo', cn.node.url_alias
      assert !cn.new_record?, "invalid node: "+cn.errors.full_messages.join(' ')
    end
  end

  def test_should_raise_on_move_to_sibling_of_root
    assert_raises ActiveRecord::ActiveRecordError do
      @about_page_node.move_to_left_of @root_node
    end
    assert_equal @root_node, @about_page_node.reload.parent
  end

  def test_should_raise_on_move_to_sibling_of_child
    assert_raises ActiveRecord::ActiveRecordError do
      @root_node.move_to_left_of @about_page_node
    end
    assert_nil @root_node.reload.parent
  end

  def test_should_raise_on_move_to_child_of_self
    assert_raises ActiveRecord::ActiveRecordError do
      @root_node.move_to_child_of @about_page_node
    end
    assert_nil @root_node.reload.parent
  end

  def test_should_raise_on_move_to_self
    assert_raises ActiveRecord::ActiveRecordError do
      @about_page_node.move_to_child_of @about_page_node
    end
    assert_equal @root_node, @about_page_node.reload.parent
  end

  def test_should_move_to_left
    n = create_page.node
    n.move_to_left_of @about_page_node
    assert_equal(@root_node, n.parent)
    assert_equal @about_page_node.reload.position - 1, n.position
  end

  def test_should_move_to_right
    n = create_page.node
    n.move_to_right_of @about_page_node
    assert_equal(@root_node, n.parent)
    assert_equal @about_page_node.reload.position + 1, n.position
  end

  def test_should_not_move_if_child_content_type_not_allowed
    n = NewsArchive.create(:parent => @root_node, :title => 'News Archive').node

    [ @root_node, @about_page_node ].each do |node|
      assert_raise ActiveRecord::ActiveRecordError do
        node.move_to_child_of(n)
      end
    end
  end

  def test_should_destroy_node
    assert_difference 'Node.count', -1 do
      @help_page_node.destroy
    end
  end

  def test_should_not_destroy_root_node
    assert_raise ActiveRecord::ActiveRecordError do
      assert_no_difference 'Node.count' do
        @root_node.destroy
      end
    end
  end

  def test_should_destroy_associated_content
    assert_difference 'Page.count', -1 do
      @about_page_node.destroy
    end
  end

   def test_should_destroy_all_children
     section       = Section.create(:parent => @root_node,    :title => 'section to destroy')
     child_section = Section.create(:parent => section.node , :title => 'inner section')

     Page.create(:parent => child_section.node , :title => 'tmp page 1', :preamble => 'help',     :body => 'help', :expires_on => 1.day.from_now.to_date)
     Page.create(:parent => child_section.node , :title => 'tmp page 2', :preamble => 'feedback', :body => 'feedback', :expires_on => 1.day.from_now.to_date)

     # assert Node.valid?, "Invalid tree structure after adding test nodes."

     assert_difference 'Node.count', -4, "Not all nodes were destroyed" do
       assert_difference 'Section.count', -2, "Not all sections were destroyed" do
         assert_difference 'Page.count', -2, "Not all pages were destroyed" do
           section.destroy
         end
       end
     end
   end

   def test_should_return_hash_for_tree_node
     tree_node = @root_node.to_tree_node_for(users(:sjoerd))
     assert tree_node.is_a?(Hash)
     assert tree_node.has_key?(:id)
     assert tree_node.has_key?(:text)
   end


   def test_should_return_hash_for_tree_node_with_roles
     tree_node = nodes(:root_section_node).to_tree_node_for(users(:editor))
     assert !tree_node[:leaf]
     assert tree_node[:disabled]
     tree_node = nodes(:devcms_news_node).to_tree_node_for(users(:editor))
     assert !tree_node[:leaf]
     assert !tree_node[:disabled]
     tree_node = nodes(:devcms_news_item_node).to_tree_node_for(users(:editor))
     assert !tree_node[:noChildNodes]
     assert !tree_node[:disabled]
   end

   def test_should_create_version_and_check_accessibility_flow
     page = create_editor_content_node(:title => "Version 1", :publication_start_date => 1.day.ago)
     node = page.node
     assert !node.publishable?
     assert_nil page.previous_version
     assert_raise(ActiveRecord::RecordNotFound) { Node.accessible.find(node.id) }

     page.update_attributes(:user => users(:editor), :title => "Version 2")
     assert !node.publishable?
     assert_nil page.previous_version
     assert_raise(ActiveRecord::RecordNotFound) { Node.accessible.find(node.id) }

     page.versions.current.approve!(users(:arthur))
     page = page.reload
     
     assert page.node.publishable?
     assert Node.accessible.find(page.node)

     page.update_attributes(:user => users(:editor), :title => "Version 3")
     page = page.reload
     
     assert page.node.publishable?
     assert_not_nil page.previous_version
     assert Node.accessible.find(page.node)
   end
  
   def test_should_not_return_news_item_children_for_menu
     assert nodes(:devcms_news_node).children.shown_in_menu.empty?
   end

   def test_should_destroy_descendants_correctly
     section = Section.create!(:parent => @economie_section_node, :title => 'foo', :description => 'bar')
     page = Page.create!(:parent => section.node, :title => 'baz', :body => "Page body", :expires_on => 1.day.from_now.to_date)
     Attachment.create!(:parent => page.node, :title => 'Park Zandweerd Matrix plannen', :file => fixture_file_upload("files/ParkZandweerdMatrixplannen.doc", 'application/msword'))
     
     assert page.reload.node.reload.destroy # the tree calls destroy on node, not on content!
     assert_equal 0, section.node.children.count
   end

   def test_should_sort_children_ascending_by_content_title
     node = nodes(:node_for_sorting)
     node.sort_children
     assert_equal ['aaa', 'BBB', 'ccc'], node.children.map { |n| n.content.content_title }
   end

   def test_should_sort_children_descending_by_created_at
     node = nodes(:node_for_sorting)
     node.sort_children :sort_by => :created_at, :order => 'desc'
     assert_equal [Time.now.day, 5.days.ago.day, 10.days.ago.day], node.children.map { |n| n.content.created_at.day }
   end

   def test_global_frontpage
     @root_section.set_frontpage!(@root_node)
     assert_equal @root_node, Node.global_frontpage
     assert_not_equal @economie_section_node, Node.global_frontpage
     @root_section.set_frontpage!(@economie_section_node)
     assert_not_equal @root_node, Node.global_frontpage
     assert_equal @economie_section_node, Node.global_frontpage
   end

   def test_is_frontpage?
     @root_section.set_frontpage!(@economie_section_node)
     assert @economie_section_node.is_frontpage?
     assert !@root_node.is_frontpage?
     @root_section.set_frontpage!(@root_node)
     assert !@economie_section_node.is_frontpage?
     assert !@root_node.is_frontpage?
   end

   def test_is_global_frontpage?
     @root_section.set_frontpage!(@root_node)
     assert !@economie_section_node.is_global_frontpage?
     assert @root_node.is_global_frontpage?
     @root_section.set_frontpage!(@economie_section_node)
     assert @economie_section_node.is_global_frontpage?
     assert !@root_node.is_global_frontpage?
   end

   def test_contains_global_frontpage?
     @root_section.set_frontpage!(@root_node)
     assert !@root_node.contains_global_frontpage? # Because it IS the global frontpage
     assert !@economie_section_node.contains_global_frontpage?
     @root_section.set_frontpage!(@economie_section_node)
     assert @root_node.contains_global_frontpage?
     assert !@economie_section_node.contains_global_frontpage? # Because it IS the global frontpage
   end

   def test_node_should_be_expandable_if_user_has_a_role_on_it
     assert nodes(:devcms_news_node).is_expandable_for_user?(@editor)
   end

   def test_node_should_be_expandable_if_user_has_a_role_on_a_descendant
     assert nodes(:root_section_node).is_expandable_for_user?(@editor)
   end

   def test_node_should_not_be_expandable_if_user_has_no_role_on_it_or_on_a_descendant
     assert !nodes(:section_with_frontpage_node).is_expandable_for_user?(@editor)
   end

   def test_determine_content_date_should_use_publication_start_date_for_news_items_and_newsletter_editions
     today                  = Time.now
     publication_start_date = 2.days.from_now

     [ create_news_item(:publication_start_date => publication_start_date, :publication_end_date => publication_start_date + 7.days),
       create_newsletter_edition(:publication_start_date => publication_start_date)].each do |item|
       assert_equal publication_start_date.to_date, item.node.determine_content_date(today.to_date)
       new_publication_start_date = 4.days.from_now
       item.__send__(:update_attributes, :publication_start_date => new_publication_start_date)
       assert_equal new_publication_start_date.to_date, item.reload.node.reload.determine_content_date(today.to_date)
     end
   end

   def test_determine_content_date_should_use_end_time_for_finished_calendar_items_and_meetings
     today      = Time.now
     start_time = Time.local(2010, 1, 1, 20 )
     end_time   = Time.local(2010, 1, 1, 21 )

     [ 
       create_calendar_item(:start_time => start_time, :end_time => end_time), 
       create_meeting(:start_time => start_time, :end_time => end_time)
     ].each do |item|
       assert_equal end_time.to_date, item.node.determine_content_date(today.to_date)
       new_end_time = Time.local(2010, 1, 1, 22)

       assert item.update_attributes!(:end_time => new_end_time)
       assert_equal new_end_time.to_date, item.node.determine_content_date(today.to_date)
     end
   end

   def test_determine_content_date_should_use_start_time_for_future_calendar_items_and_meetings
     today      = Time.now
     start_time = 2.days.from_now
     end_time   = 3.days.from_now

     [ create_calendar_item(:start_time => start_time, :end_time => end_time),
       create_meeting(:start_time => start_time, :end_time => end_time)].each do |item|
       assert_equal start_time.to_date, item.node.determine_content_date(today.to_date)
       new_start_time = 4.days.from_now
       item.update_attribute(:start_time, new_start_time)
       assert_equal new_start_time.to_date, item.reload.node.reload.determine_content_date(today.to_date)
     end
   end

   def test_method_content_class
     @meetings_calendar_meeting_one_node = nodes(:meetings_calendar_meeting_one_node)
     @external_link_node                 = nodes(:external_link_node)
     @internal_link_node                 = nodes(:internal_link_node)

     assert_equal @root_node.content.class, @root_node.content_class
     assert_equal @meetings_calendar_meeting_one_node.content.class, @meetings_calendar_meeting_one_node.content_class
     assert_equal @external_link_node.content.class, @external_link_node.content_class
   end

   def test_changes_should_not_include_unpublished_new_items
     size = nodes(:devcms_news_node).last_changes(:all).size
     n1= create_news_item(:publication_start_date => 2.days.ago, :publication_end_date => 1.day.from_now, :title => "Beschikbaar")
     create_news_item(:publication_start_date => 2.days.from_now, :publication_end_date => 3.day.from_now , :title => "Nog niet beschikbaar")
     create_news_item(:publication_start_date => 2.days.ago, :publication_end_date => 1.day.ago, :title => "Niet meer beschikbaar")
     changes = nodes(:devcms_news_node).last_changes(:all)

     assert_equal size+1, changes.size
     assert_nil(    changes.reject! { |node| !node.content.respond_to?(:title) || node.content.title == "Nog niet beschikbaar"  }, "Not yet published items should not be shown")
     assert_nil(    changes.reject! { |node| !node.content.respond_to?(:title) || node.content.title == "Niet meer beschikbaar" }, "No longer published items should not be shown")
     assert_not_nil(changes.reject! { |node| !node.content.respond_to?(:title) || node.content.title == "Beschikbaar"           }, "Published items should not have been deleted")
   end

   def test_changes_should_not_include_feeds
     assert_not_nil Node.all(:conditions => { :content_type => 'Feed'}), "Should have at least one feed to test for exclusion"
     assert @root_node.last_changes(:all).select{ |n| n.content_class == Feed }.empty?
   end

   def test_changes_should_only_include_accessible_children
     assert_nil @root_node.last_changes(:all).reject! { |n| !n.publishable? }
   end

   def test_changes_should_accept_limit
     assert_equal  5, @root_node.last_changes(:all,:limit =>  5).size
     assert_equal 15, @root_node.last_changes(:all,:limit => 15).size
   end

  def test_changes_should_return_self
    ni = create_news_item(:publication_start_date => 2.days.ago, :publication_end_date => 1.day.from_now, :title => "Beschikbaar")
    changes = nodes(:devcms_news_node).last_changes(:self)
    assert changes.include?(nodes(:devcms_news_node))
  end

   def test_increment_hits
     node = create_page.node
     assert_equal 0, node.hits
     node.increment_hits!
     assert_equal 1, node.reload.hits
   end

   def test_should_protect_hits_attribute
     node = create_page.node
     assert_equal 0, node.hits
     
     assert_raises ActiveModel::MassAssignmentSecurity::Error do
       node.update_attributes(:hits => 1)
     end
   end

   def test_find_accessible_should_only_find_published_nodes
     # Published nodes
     [ [ 1.day.ago, nil ], [ 1.day.ago, 1.day.from_now ] ].map do | start_date, end_date |
       page = create_page
       page.update_attributes(:publication_start_date => start_date, :publication_end_date => end_date)
       assert !page.new_record?
       assert_equal page.node, Node.accessible.find(page.node.id)
     end

     # Unpublished nodes
     [ [ 2.days.ago, 1.day.ago ], [ 1.day.from_now, nil ], [ 1.day.from_now, 2.days.from_now ] ].map do | start_date, end_date |
       page = create_page
       page.update_attributes(:publication_start_date => start_date, :publication_end_date => end_date)
       assert !page.new_record?

       assert_raise ActiveRecord::RecordNotFound do
         Node.accessible.find page.node.id
       end
     end
   end

   def test_should_reduce_number_of_hits_on_all_nodes
     first_page_node  = create_page.node
     second_page_node = create_page.node
     third_page_node  = create_page.node

     first_page_node.update_attribute( :hits, 3000)
     second_page_node.update_attribute(:hits, 1000)
     third_page_node.update_attribute( :hits, 2000)

     Node.reduce_hit_count

     assert_equal 300, first_page_node.reload.hits
     assert_equal 100, second_page_node.reload.hits
     assert_equal 200, third_page_node.reload.hits
   end

  def test_should_accept_category
    category = Category.create(:name => 'Economy')
    @economie_section_node.categories << category
    assert @economie_section_node.valid?
    assert !@economie_section_node.categories.empty?
  end

  def test_should_find_related_nodes
    category = Category.create(:name => 'Related')
    @economie_section_node.categories << category
    @about_page_node.categories << category
    assert Node.find_related_nodes(@economie_section_node, :top_node => @root_node).include?(@about_page_node)
  end

  def test_should_set_position_on_create
    Node.root.reorder_children
    n = create_node
    assert_not_nil n.position
    assert_not_equal 0, n.position
    assert n.last?

    assert_not_nil create_node.position
  end

  def test_should_set_categories_while_keeping_existing
    n = create_node

    category1 = Category.create(:name => 'Categorie 1')
    category2 = Category.create(:name => 'Categorie 2')
    
    n.keep_existing_categories = true
    n.category_ids=([ category1.id, category2.id ])

    assert n.categories.include?(category1)
    assert n.categories.include?(category2)

    category3 = Category.create(:name => 'Categorie 3')
    category4 = Category.create(:name => 'Categorie 4')

    n.category_ids=([ category2.id, category3.id, category4.id ])

    assert n.categories.include?(category1)
    assert n.categories.include?(category2)
    assert n.categories.include?(category3)
    assert n.categories.include?(category4)
  end

  def test_should_set_categories_while_not_keeping_existing
    n = create_node

    category1 = Category.create(:name => 'Categorie 1')
    category2 = Category.create(:name => 'Categorie 2')
    
    n.keep_existing_categories = true
    n.category_ids=([ category1.id, category2.id ])

    assert n.categories.include?(category1)
    assert n.categories.include?(category2)

    category3 = Category.create(:name => 'Categorie 3')
    category4 = Category.create(:name => 'Categorie 4')
    
    n.keep_existing_categories = false
    n.category_ids=([ category2.id, category3.id, category4.id ])

    assert n.categories.include?(category2)
    assert n.categories.include?(category3)
    assert n.categories.include?(category4)
  end

  def test_bulk_update_should_return_true_if_updating_succeeds_for_all_nodes
    node1 = stub(:content => stub(:update_attributes! => true, :class => stub(:requires_editor_approval? => false)))
    node2 = stub(:content => stub(:update_attributes! => true, :class => stub(:requires_editor_approval? => false)))
    assert_equal true, Node.bulk_update([ node1, node2 ], {})
  end

  def test_bulk_update_should_return_false_if_updating_fails_for_one_of_the_nodes
    content = stub(:class => { :requires_editor_approval? => false })
    content.stubs(:update_attributes!).raises(ActiveRecord::RecordInvalid)
    node1 = stub(:content => content)
    
    content = stub(:update_attributes! => true, :class => stub(:requires_editor_approval? => false))
    node2 = stub(:content => content)
    
    assert_equal false, Node.bulk_update([ node1, node2 ], {})
  end
  
  def test_should_save_category_attributes_to_associated_categories_on_save
    n = create_node

    category1 = Category.create(:name => 'Categorie 1')
    category2 = Category.create(:name => 'Categorie 2')

    n.category_ids=([ category1.id, category2.id ])

    n.update_attributes(:category_attributes => {
      category1.id => { :synonyms => 'Categorie 1' },
      category2.id => { :synonyms => 'Categorie 2' },
    })

    assert_equal 'Categorie 1', category1.reload.synonyms
    assert_equal 'Categorie 2', category2.reload.synonyms
  end

  def test_containing_site
    assert_equal nodes(:root_section_node),     nodes(:help_page_node).containing_site
    assert_equal nodes(:sub_site_section_node), nodes(:yet_another_page_node).containing_site
    assert_equal nodes(:sub_site_section_node), nodes(:sub_site_section_node).containing_site
    assert_equal nodes(:root_section_node),     nodes(:root_section_node).containing_site
  end
  
  def test_should_register_content_type_and_configuration
    Node.register_content_type(Page, Node.content_type_configuration('Page').merge({:enabled => "TestTestTest"}))
    assert_not_nil Node.content_type_configuration('Page')
    assert_equal "TestTestTest", Node.content_type_configuration('Page')[:enabled]
    Node.register_content_type(Page, Node.content_type_configuration('Page').merge({:enabled => true}))
  end

  def test_should_not_update_postions_in_subtree_on_move
    node = nodes(:devcms_news_node)
    node.descendants.update_all(:position => 99)
    assert node.descendants.all? {|n| n.position == 99}, "Should have set all descendant positions!"
    node.move_to_child_of nodes(:economie_section_node)
    assert node.descendants.all? {|n| n.position == 99}, "Should not have updated positions!"
  end

protected

  def create_node(options = {}, parent_node = nodes(:root_section_node))
    create_page({:parent => parent_node}.merge(options)).node
  end

  def create_news_item(options = {})
    NewsItem.create({ :user => @arthur, :parent => nodes(:devcms_news_node), :title => "Slecht weer!", :body => "Het zonnetje schijnt niet en de mensen zijn ontevreden.", :publication_start_date => 1.day.ago, :publication_end_date => 1.day.from_now }.merge(options))
  end

  def create_newsletter_edition(options = {})
    NewsletterEdition.create({ :parent => nodes(:newsletter_archive_node), :title => "Het maandelijkse nieuws!", :body => "O o o wat is het weer een fijne maand geweest.", :publication_start_date => 1.hour.from_now }.merge(options))
  end

  def create_calendar_item(options = {})
    CalendarItem.create({ :parent => nodes(:meetings_calendar_node), :repeating => false, :title => "New event", :start_time => Time.now, :end_time => 1.hour.from_now }.merge(options))
  end

  def create_meeting(options = {})
    Meeting.create({ :parent => nodes(:meetings_calendar_node), :repeating => false, :meeting_category => meeting_categories(:gemeenteraad_meetings), :title => "New meeting", :start_time => Time.now, :end_time => 1.hour.from_now }.merge(options))
  end

  def create_page(options = {})
    Page.create({ :user => @arthur, :parent => nodes(:root_section_node), :title => 'foo', :preamble => 'xuu', :body => 'bar' }.merge(options))
  end

  def create_section(options={})
    Section.create({ :user => @arthur, :parent => nodes(:root_section_node), :title => 'new section', :description => 'new description for section.' }.merge(options))
  end

  def create_editor_content_node(options = {})
    Page.create({ :user => users(:editor), :parent => nodes(:editor_section_node), :title => 'foo', :preamble => 'xuu', :body => 'bar', :expires_on => 1.day.from_now.to_date }.merge(options))
  end

end
