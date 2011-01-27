require File.dirname(__FILE__) + '/../test_helper'

class UserCategoryTest < ActiveSupport::TestCase
  def setup
    @user = users(:arthur)
    @category = categories(:category_blaat)
  end

  def test_should_create_user_category
    assert_difference 'UserCategory.count' do
      uc = create_user_category
      assert uc.valid?
    end
  end

  def test_should_require_user
    assert_no_difference 'UserCategory.count' do
      uc = create_user_category(:user => nil)
      assert uc.errors.on(:user)
    end
  end

  def test_should_require_category
    assert_no_difference 'UserCategory.count' do
      uc = create_user_category(:category => nil)
      assert uc.errors.on(:category)
    end
  end

  def test_should_require_unique_category_user_combination
    assert_difference 'UserCategory.count' do
      uc = create_user_category
      assert uc.valid?
    end

    assert_no_difference 'UserCategory.count' do
      uc = create_user_category
      assert uc.errors.on(:category_id)
    end
  end
  
protected
  
  def create_user_category(options = {})
    UserCategory.create({ :user => @user, :category => @category }.merge(options))
  end
end
