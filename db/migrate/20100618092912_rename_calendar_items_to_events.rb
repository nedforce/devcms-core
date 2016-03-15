class RenameCalendarItemsToEvents < ActiveRecord::Migration
  class Node < ActiveRecord::Base; end

  def up
    rename_table :calendar_items, :events

    Node.where("#{Node.quoted_table_name}.content_type = 'CalendarItem'").update_all "content_type = 'Event'"
  end

  def down
    rename_table :events, :calendar_items

    Node.where("#{Node.quoted_table_name}.content_type = 'Event'").update_all "content_type = 'CalendarItem'"
  end
end
