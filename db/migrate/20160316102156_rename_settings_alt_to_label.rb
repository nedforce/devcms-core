class RenameSettingsAltToLabel < ActiveRecord::Migration

  def change
    rename_column :settings, :alt, :label
  end

end
