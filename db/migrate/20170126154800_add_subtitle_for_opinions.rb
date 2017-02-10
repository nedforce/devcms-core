class AddSubtitleForOpinions < ActiveRecord::Migration
  def change
    add_column :opinions, :subtitle, :string
  end

end
