require File.expand_path('../../test_helper.rb', __FILE__)

class RoleAssignmentTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  test 'should create role assignment' do
    assert_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment
      assert !role_assignment.new_record?, "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end

  test 'should require uniqueness' do
    create_role_assignment

    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment
      assert "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end

  test 'should require fixed node types' do
    [nodes(:test_image_two_node), nodes(:devcms_news_item_node), nodes(:events_calendar_item_one_node)].each do |node|
      assert_no_difference 'RoleAssignment.count' do
        role_assignment = create_role_assignment(name: 'editor', node: node)
        assert "#{role_assignment.errors.full_messages.to_sentence}"
      end
    end

    [nodes(:about_page_node), nodes(:devcms_news_node), nodes(:events_calendar_node)].each do |node|
      assert_difference 'RoleAssignment.count', 1 do
        users(:klaas).promote!
        role_assignment = create_role_assignment(name: 'editor', node: node, user: users(:klaas))
        assert role_assignment.errors.empty?, role_assignment.errors.full_messages.to_sentence
      end
    end
  end

  test 'should require root node for admin' do
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(name: 'admin', node: nodes(:test_image_two_node))
      assert "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end

  test 'should require no inherited roles' do
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(user: users(:arthur))
      assert "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end

  test 'should require node' do
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(node: nil)
      assert role_assignment.errors[:node].any?
    end
  end

  test 'should require name' do
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(name: nil)
      assert role_assignment.errors[:name].any?
    end
  end

  test 'should require valid name' do
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(name: 'this_is_not_a_role')
      assert role_assignment.errors[:name].any?
    end
  end

  test 'should require user' do
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(user: nil)
      assert role_assignment.errors[:user].any?
    end
  end

  test 'should require privileged user' do
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(user: users(:klaas))
      assert role_assignment.errors[:user].any?
    end
  end

  protected

  def create_role_assignment(options = {})
    RoleAssignment.create({
      user: users(:editor),
      node: nodes(:about_page_node),
      name: 'final_editor'
    }.merge(options))
  end
end
