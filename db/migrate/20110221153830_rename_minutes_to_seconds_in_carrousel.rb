class RenameMinutesToSecondsInCarrousel < ActiveRecord::Migration
  def self.up
    rename_column :carrousels, :display_time_in_minutes, :display_time_in_seconds
    say_with_time "Updating times" do
      carrousels = Carrousel.all
      carrousels.each do |c|
        c.update_attribute(:display_time_in_seconds, c.display_time_in_seconds * 60)
        say "#{c.title} updated!", true
      end
    end
  end

  def self.down
    rename_column :carrousels, :display_time_in_seconds, :display_time_in_minutes
    say_with_time "Updating times" do
      carrousels = Carrousel.all
      carrousels.each do |c|
        c.update_attribute(:display_time_in_minutes, (c.display_time_in_minutes / 60).to_i)
        say "#{c.title} updated!", true
      end
    end
  end
end
