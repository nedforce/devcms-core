class AddLastCheckedAtToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :last_checked_at, :datetime
  end
end
