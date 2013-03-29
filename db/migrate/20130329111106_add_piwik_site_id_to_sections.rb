class AddPiwikSiteIdToSections < ActiveRecord::Migration
  def change
    add_column :sections, :piwik_site_id, :string
  end
end
