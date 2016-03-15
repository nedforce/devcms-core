class MoveLinksBoxesToOwnTable < ActiveRecord::Migration
  unless Rails.env.production?
    class Section < ActiveRecord::Base
    end

    class LinksBox < ActiveRecord::Base
    end
  end

  def up
    create_table :links_boxes do |t|
      t.string :title, null: false
      t.text   :description

      t.timestamps
    end

    Section.where(type: 'LinksBox').each do |links_box|
      new_id = ActiveRecord::Base.connection.insert("INSERT INTO links_boxes (title, description, created_at, updated_at) VALUES ('#{links_box.title}', '#{links_box.description}', '#{links_box.created_at}', '#{links_box.updated_at}')")
      Node.where("content_id = #{links_box.id} AND content_type = 'Section'").update_all("content_id = #{new_id}, content_type = 'LinksBox'")
    end

    Section.where("type = 'LinksBox'").delete_all
  end

  def down
    LinksBox.all.each do |links_box|
      new_id = ActiveRecord::Base.connection.insert("INSERT INTO sections (type, title, description, created_at, updated_at) VALUES ('LinksBox', '#{links_box.title}', '#{links_box.description}', '#{links_box.created_at}', '#{links_box.updated_at}')")
      Node.where("content_id = #{links_box.id} AND content_type = 'LinksBox'").update_all("content_id = #{new_id}, content_type = 'Section'")
    end

    drop_table :links_boxes
  end
end
