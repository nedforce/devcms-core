require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +AgendaItemCategory+ model.
class AgendaItemCategoryTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @agenda_item_category = agenda_item_categories(:hamerstukken)
  end

  test 'should create agenda item category' do
    assert_difference 'AgendaItemCategory.count' do
      create_agenda_item_category
    end
  end

  test 'should require name' do
    assert_no_difference 'AgendaItemCategory.count' do
      agenda_item_category = create_agenda_item_category(name: nil)
      assert agenda_item_category.errors[:name].any?
    end
  end

  test 'should require unique name' do
    assert_no_difference 'AgendaItemCategory.count' do
      agenda_item_category = create_agenda_item_category(name: @agenda_item_category.name)
      assert agenda_item_category.errors[:name].any?
    end
  end

  test 'should update agenda item category' do
    assert_no_difference 'AgendaItemCategory.count' do
      @agenda_item_category.name = 'New name'
      assert @agenda_item_category.save
    end
  end

  test 'should destroy agenda item category' do
    assert_difference 'AgendaItemCategory.count', -1 do
      @agenda_item_category.destroy
    end
  end

  test 'should not destroy associated agenda items' do
    agenda_items = @agenda_item_category.agenda_items

    assert_no_difference 'AgendaItem.count' do
      @agenda_item_category.destroy
    end

    agenda_items.each do |agenda_item|
      assert_nil agenda_item.agenda_item_category
    end
  end

  test 'should find or new by name' do
    aic1 = create_agenda_item_category

    assert_no_difference 'AgendaItemCategory.count' do
      assert_equal aic1, AgendaItemCategory.find_or_new_by_name(aic1.name)
      aic2 = AgendaItemCategory.find_or_new_by_name('doesnotexist')
      assert aic2.new_record?
      assert_equal 'doesnotexist', aic2.name
    end
  end

  protected

  def create_agenda_item_category(options = {})
    AgendaItemCategory.create({ name: 'Foobarbazquux' }.merge(options))
  end
end
