class RenameMinutesToSecondsInCarrousel < ActiveRecord::Migration
  def up
    rename_column :carrousels, :display_time_in_minutes, :display_time_in_seconds

    Carrousel.reset_column_information
    if Carrousel.unscoped.count > 0
      say_with_time 'Updating times' do
        Carrousel.all.each do |c|
          c.update_attribute(:display_time_in_seconds, c.display_time_in_seconds * 60)
          say "#{c.title} updated!", true
        end
      end
    end
  end

  def down
    rename_column :carrousels, :display_time_in_seconds, :display_time_in_minutes

    Carrousel.reset_column_information
    if Carrousel.unscoped.count > 0
      say_with_time 'Updating times' do
        Carrousel.all.each do |c|
          c.update_attribute(:display_time_in_minutes, (c.display_time_in_minutes / 60).to_i)
          say "#{c.title} updated!", true
        end
      end
    end
  end
end
