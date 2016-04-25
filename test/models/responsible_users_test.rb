require File.expand_path('../../test_helper.rb', __FILE__)

class ResponsibleUsersTest < ActiveSupport::TestCase
  def test_should_set_responsible_user_to_current_user_for_editor
    ni = create_news_item user: users(:editor)
    refute ni.new_record?
    assert_equal users(:editor), ni.node.responsible_user
  end

  def test_should_not_set_responsible_user_to_other_user_for_editor
    ni = create_news_item user: users(:editor), responsible_user: users(:arthur)
    refute ni.new_record?
    assert_equal users(:editor), ni.node.responsible_user
  end

  def test_should_not_set_responsible_user_to_non_priviliged
    ni = create_news_item responsible_user: users(:reader)
    assert ni.new_record?
    assert_not_nil ni.errors
  end

  def test_should_set_responsible_user_to_none_for_admin
    ni = create_news_item user: users(:arthur)
    refute ni.new_record?
    assert_nil ni.node.responsible_user
  end

  def test_should_set_responsible_user_to_other_user_for_admin
    ni = create_news_item user: users(:arthur), responsible_user: users(:editor)
    refute ni.new_record?
    assert_equal users(:editor), ni.node.responsible_user
  end

  protected

  def create_news_item(options = {})
    NewsItem.create({
      parent: nodes(:devcms_news_node),
      title: 'Test bericht',
      body: 'Test text'
    }.merge(options))
  end
end
