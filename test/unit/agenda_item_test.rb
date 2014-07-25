require File.expand_path('../../test_helper.rb', __FILE__)

class AgendaItemTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @calendar_item = events(:events_calendar_item_one)
    @meeting = events(:meetings_calendar_meeting_one)
    @agenda_item_category = agenda_item_categories(:hamerstukken)
    @agenda_item_category_two = agenda_item_categories(:stukken_ter_kennisname)
    @agenda_item = agenda_items(:agenda_item_one)
  end
  
  def test_should_create_agenda_item
    assert_difference 'AgendaItem.count' do
      create_agenda_item
    end
  end

  def test_should_require_parent
    assert_no_difference 'AgendaItem.count' do
      agenda_item = create_agenda_item(:parent => nil)
      assert agenda_item.errors[:calendar_item].any?
    end
  end
  
  def test_should_not_require_body
    assert_difference 'AgendaItem.count', 1 do
      agenda_item = create_agenda_item(:body => nil)
      assert !agenda_item.errors[:body].any?
    end
  end
  
  def test_should_not_require_speaking_rights_option
    assert_difference 'AgendaItem.count', 1 do
      agenda_item = create_agenda_item(:speaking_rights => nil)
      assert !agenda_item.errors[:speaking_rights].any?
    end
  end
  
  def test_should_not_require_agenda_item_category
    assert_difference 'AgendaItem.count', 1 do
      agenda_item = create_agenda_item(:agenda_item_category => nil)
      assert !agenda_item.errors[:agenda_item_category].any?
    end
  end
  
  def test_should_require_description
    assert_no_difference 'AgendaItem.count' do
      agenda_item = create_agenda_item(:description => nil)
      assert agenda_item.errors[:description].any?
    end
  end
  
  def test_should_require_valid_speaking_rights_option
    assert_no_difference 'AgendaItem.count' do
      agenda_item = create_agenda_item(:speaking_rights => 'foo')
      assert agenda_item.new_record?
      assert agenda_item.errors[:speaking_rights].any?
    end
    
    assert_no_difference 'AgendaItem.count' do
      agenda_item = create_agenda_item(:speaking_rights => AgendaItem::SPEAKING_RIGHT_OPTIONS.keys.max + 1)
      assert agenda_item.new_record?
      assert agenda_item.errors[:speaking_rights].any?
    end
  end
  
  def test_agenda_item_category_name_should_return_nil_if_no_agenda_item_category_is_associated
    agenda_item = create_agenda_item(:agenda_item_category => nil)
    assert_equal nil, agenda_item.agenda_item_category_name
  end
  
  def test_agenda_item_category_name_should_return_name_of_associated_agenda_item_category_if_an_agenda_item_category_is_associated
    agenda_item = create_agenda_item
    assert_equal agenda_item.agenda_item_category.name, agenda_item.agenda_item_category_name
  end
  
  def test_agenda_item_category_name_should_associate_existing_agenda_item_category_on_create
    assert_no_difference('AgendaItemCategory.count') do
      agenda_item = create_agenda_item({ :agenda_item_category_name => @agenda_item_category.name, :description => "Spannend!", :body => 'Geen grappen!'})
      assert_equal @agenda_item_category, agenda_item.agenda_item_category
    end
  end

  def test_agenda_item_category_name_should_associate_existing_agenda_item_category_on_update
    assert_no_difference('AgendaItemCategory.count') do
      @agenda_item.agenda_item_category_name = @agenda_item_category_two.name
      @agenda_item.save
      assert_equal @agenda_item_category_two, @agenda_item.agenda_item_category
    end
  end

  def test_agenda_item_category_name_should_create_new_agenda_item_category_for_valid_name
    assert_difference('AgendaItemCategory.count', 1) do
      @agenda_item.agenda_item_category_name = 'foo'
      @agenda_item.save
      assert_equal AgendaItemCategory.find_by_name('foo'), @agenda_item.agenda_item_category
    end
  end

  def test_agenda_item_category_name_should_not_create_new_agenda_item_category_for_blank_name
    assert_no_difference('AgendaItemCategory.count') do
      old_agenda_item_category = @agenda_item.agenda_item_category
      @agenda_item.agenda_item_category_name = nil
      @agenda_item.save
      assert_equal old_agenda_item_category, @agenda_item.reload.agenda_item_category
    end
  end

  def test_agenda_item_category_name_should_not_create_new_agenda_item_category_for_invalid_name
    assert_no_difference('AgendaItemCategory.count') do
      old_agenda_item_category = @agenda_item.agenda_item_category
      @agenda_item.agenda_item_category_name = 'a'
      @agenda_item.save
      assert_equal old_agenda_item_category, @agenda_item.reload.agenda_item_category
    end
  end
  
  def test_should_update_agenda_item
    assert_no_difference 'AgendaItem.count' do
      @agenda_item.description = 'New title'
      assert @agenda_item.save(:user => users(:arthur))
    end
  end
  
  def test_should_destroy_agenda_item
    assert_difference "AgendaItem.count", -1 do
      @agenda_item.destroy
    end
  end
  
  def test_should_not_return_agenda_item_children_for_menu
    assert @meeting.node.children.accessible.shown_in_menu.empty?
  end
  
  def test_content_title_should_return_description
    assert_equal @agenda_item.description, @agenda_item.content_title
  end

protected

  def create_agenda_item(options = {})
    AgendaItem.create({ :parent => nodes(:meetings_calendar_meeting_one_node), :agenda_item_category => @agenda_item_category, :description => 'Spannend!', :body => 'Geen grappen!' }.merge(options))
  end
end
