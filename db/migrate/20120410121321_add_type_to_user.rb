class AddTypeToUser < ActiveRecord::Migration
  def up
    add_column :users, :type, :string

    ids = RoleAssignment.where(name: %w(admin editor final_editor)).pluck(:user_id).uniq
    puts User.where(id: ids).update_all(type: 'PrivilegedUser')
  end

  def down
    remove_column :users, :type
  end
end
