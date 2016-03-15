class AddAnimationToCarrousel < ActiveRecord::Migration
  def up
    add_column :carrousels, :animation, :integer
  end

  def down
    remove_column :carrousels, :animation
  end
end
