class CreateThemes < ActiveRecord::Migration
  def self.up
    if table_exists?(:research_themes)
      rename_table  :research_themes, :themes
      add_column    :themes, :type, :string, :null => true
      Theme.reset_column_information
      Theme.update_all :type => 'ResearchTheme'
      Node.update_all({:content_type => 'Theme', :sub_content_type => "ResearchTheme"},{:content_type => 'ResearchTheme'} )
      change_column :themes, :type, :string, :null => false
    else
      create_table :themes do |t|
        t.string  :title, :null => false
        t.string  :type
        t.timestamps
      end
    end
  end

  def self.down
    rename_table  :themes, :research_themes
    remove_column :research_themes, :type
  end
end
