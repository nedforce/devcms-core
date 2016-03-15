class RenameAgendaItemCalendarItemIdToEventId < ActiveRecord::Migration
  def up
    rename_column :agenda_items, :calendar_item_id, :event_id
  end

  def down
    rename_column :agenda_items, :event_id, :calendar_item_id
  end
end
