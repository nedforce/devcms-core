class AddTypeToUser < ActiveRecord::Migration
  def self.up
  	add_column :users, :type, :string
  	ids = RoleAssignment.all(:select => :user_id, :conditions => {:name => %w(admin editor final_editor)}).collect(&:user_id).uniq
  	puts User.update_all({:type => 'PrivilegedUser'}, {:id => ids})
  end

  def self.down
  	remove_column :users, :type
  end
end
