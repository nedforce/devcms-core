class AddMetaDescriptionToSections < ActiveRecord::Migration
  def change
    add_column :sections, :meta_description, :string
  end
end
