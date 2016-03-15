class AddDeletedAtToContentNodes < ActiveRecord::Migration
  def up
    puts 'Copying deleted_at values for all nodes, this might take a while.'

    content_type_tables.each do |content_type_table|
      next unless ActiveRecord::Base.connection.table_exists?(content_type_table)

      add_column content_type_table, :deleted_at, :datetime
      add_index  content_type_table, :deleted_at

      ActiveRecord::Base.connection.execute("UPDATE #{content_type_table} SET deleted_at = nodes.deleted_at FROM nodes WHERE nodes.content_type = '#{content_type_table.to_s.classify}' AND nodes.content_id = #{content_type_table}.id AND nodes.deleted_at IS NOT NULL")
    end

    puts 'Successfully copied deleted_at values for all nodes.'
  end

  def down
    content_type_tables.each do |content_type_table|
      remove_column content_type_table, :deleted_at
    end
  end

  def content_type_tables
    DevcmsCore::Engine.registered_content_types.map(&:constantize).map(&:table_name).uniq
  end
end
