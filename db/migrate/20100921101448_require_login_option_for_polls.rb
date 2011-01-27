class RequireLoginOptionForPolls < ActiveRecord::Migration
  def self.up
    add_column :polls, :requires_login, :boolean, :default => false
    create_table :user_poll_question_votes do |table|
      table.integer :user_id, :references => :users
      table.integer :poll_question_id, :references => :poll_questions
      table.timestamps
    end
  end

  def self.down
    remove_colum :polls, :requires_login
    drop_table :user_poll_question_votes
  end
end
