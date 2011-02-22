class AddAnimationToCarrousel < ActiveRecord::Migration
  def self.up
    add_column :carrousels, :animation, :integer
  end

  def self.down
    remove_column :carrousels, :animation
  end
end
