class AddMetaDescriptionToPagesAndNewsItems < ActiveRecord::Migration
  def change
    add_column :pages,      :meta_description, :string
    add_column :news_items, :meta_description, :string
  end
end
