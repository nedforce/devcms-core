class MigrateLayoutSettings < ActiveRecord::Migration
  # Faux models to avoid this migration to break
  class SideBoxElement < ActiveRecord::Base
    belongs_to :parent,  class_name: 'Node'
    belongs_to :content, class_name: 'Node'
  end

  class Template < ActiveRecord::Base
    has_many :nodes
  end

  class ContentRepresentation < ActiveRecord::Base
    belongs_to :parent,  class_name: 'Node'
    belongs_to :content, class_name: 'Node'
  end

  def up
    say_with_time 'Stop using the Template model' do
      Template.all.each do |template|
        template.nodes.each do |node|
          Node.where(id: node.id).update_all template_id: nil, layout: template.filename, layout_variant: :default, layout_configuration: { 'template_color' => template.filename }.to_yaml
        end
      end

      say 'Destroy all templates', true
      Template.destroy_all
    end

    Node.reset_column_information
    if Node.unscoped.count > 0
      say_with_time 'Convert booleans to layout variants' do
        Node.where(columns_mode: true).each do |node|
          Node.where(id: node.id).update_all layout: node.own_or_inherited_layout.id, layout_variant: 'four_columns'
        end

        Node.where(hide_right_column: true).each do |node|
          Node.where(id: node.id).update_all layout: node.own_or_inherited_layout.id, layout_variant: 'two_columns'
        end
      end
    end

    say_with_time 'Convert SideBoxElements to ContentRepresentations' do
      SideBoxElement.destroy_all.each do |sbe|
        ContentRepresentation.create!(
          parent:   sbe.parent,
          content:  sbe.content,
          position: sbe.v_position,
          target:   %w(primary_column secondary_column primary_content_column secondary_content_column)[sbe.h_position]
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
