class RenameCalendarItemsToEvents < ActiveRecord::Migration
  class Node < ActiveRecord::Base; end

  def self.up
    rename_table :calendar_items, :events

    Node.update_all "content_type = 'Event'", "#{Node.quoted_table_name}.content_type = 'CalendarItem'"
  end

  def self.down
    rename_table :events, :calendar_items

    Node.update_all "content_type = 'CalendarItem'", "#{Node.quoted_table_name}.content_type = 'Event'"
  end
end