require File.dirname(__FILE__) + '/../test_helper'

class ResponsibleUsersTest < ActiveSupport::TestCase
  
  def test_should_set_responsible_user_to_current_user_for_editor
    ni = NewsItem.create(:user => users(:editor), :parent => nodes(:devcms_news_node), :title => "Test bericht", :body => "Test tekst")
    assert !ni.new_record?
    assert_equal users(:editor), ni.node.responsible_user
  end
  
  def test_should_not_set_responsible_user_to_other_user_for_editor
    ni = NewsItem.create(:user => users(:editor), :parent => nodes(:devcms_news_node), :title => "Test bericht", :body => "Test tekst", :responsible_user => users(:arthur))
    assert !ni.new_record?
    assert_equal users(:editor), ni.node.responsible_user
  end
  
  def test_should_not_set_responsible_user_to_non_priviliged
    ni = NewsItem.create(:parent => nodes(:devcms_news_node), :title => "Test bericht", :body => "Test tekst", :responsible_user => users(:reader))
    assert ni.new_record?
    assert_not_nil ni.errors
  end
  
  def test_should_set_responsible_user_to_none_for_admin
    ni = NewsItem.create(:user => users(:arthur), :parent => nodes(:devcms_news_node), :title => "Test bericht", :body => "Test tekst")
    assert !ni.new_record?
    assert_nil ni.node.responsible_user
  end
  
  def test_should_set_responsible_user_to_other_user_for_admin
    ni = NewsItem.create(:user => users(:arthur), :parent => nodes(:devcms_news_node), :title => "Test bericht", :body => "Test tekst", :responsible_user => users(:editor))
    assert !ni.new_record?
    assert_equal users(:editor), ni.node.responsible_user
  end
  
end
