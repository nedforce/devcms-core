class AddGoogleSearchEngineToSection < ActiveRecord::Migration
  def change
    add_column :sections, :google_search_engine, :string
  end
end
