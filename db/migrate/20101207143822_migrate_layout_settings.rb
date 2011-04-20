class MigrateLayoutSettings < ActiveRecord::Migration

  class SideBoxElement < ActiveRecord::Base
    # The node whose side box contains the side box element.
     belongs_to :parent, :class_name => 'Node'

     # The node contained within the side box element.
     belongs_to :content, :class_name => 'Node'
  end
  
  class Template < ActiveRecord::Base
    has_many :nodes
  end
  
  ContentRepresentation.send(:attr_accessor, :custom_type)
      
  def self.up
    
    Node.all(:conditions => "nodes.layout IS NOT NULL OR nodes.layout_variant IS NOT NULL OR nodes.layout_configuration IS NOT NULL").each do |node|
      node.reset_layout
    end
    ContentRepresentation.destroy_all
    
    Node.all(:conditions => {:columns_mode => true}).each do |node|
      node.update_attributes!(:layout => 'default', :layout_variant => 'four_columns')
    end
    raise "Migration of 4 columns mode failed!" unless Node.count(:conditions => {:columns_mode => true}) == Node.count(:conditions => {:layout_variant => 'four_columns'})

    Node.all(:conditions => {:hide_right_column => true}).each do |node|
      node.update_attributes!(:layout => 'default', :layout_variant => 'two_columns')
    end
    raise "Migration of 2 columns mode failed!" unless Node.count(:conditions => {:hide_right_column => true}) == Node.count(:conditions => {:layout_variant => 'two_columns'})
        
    SideBoxElement.all.each do |sbe|
      cr = ContentRepresentation.new({
        :parent => sbe.parent, 
        :content => sbe.content, 
        :position => sbe.v_position, 
        :target => ['primary_column', 'secondary_column', 'primary_content_column',  'secondary_content_column'][sbe.h_position]
      })
      unless cr.valid?
        pp cr
        pp cr.errors.to_xml
      end
      cr.save!
    end
    raise "Migration of SideBoxes failed!" unless ContentRepresentation.count == SideBoxElement.count
    
    count = 0
    Template.all.each do |template|
      count += template.nodes.count
      template.nodes.each do |node|
        if template.filename != 'cjg'
          node.update_attributes! :layout_configuration => {'template_color' => template.filename }
        else
          count -= 1
          node.update_attributes! :layout => 'cjg'
        end
      end
    end
    raise "setting colors failed!" unless count == Node.count(:conditions => "nodes.layout_configuration IS NOT NULL")
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
