class AddCustomTypeToContentRepresentations < ActiveRecord::Migration
  def self.up
    add_column :content_representations, :custom_type, :string
    change_column :content_representations, :content_id, :integer, :null => true, :references => :nodes, :on_delete => :cascade
    
    count = ContentRepresentation.count
    diff = ContentRepresentation.count(:conditions => "content_representations.target = 'secondary_column'", :group => :parent_id).keys.size + ContentRepresentation.count(:conditions => "content_representations.target = 'primary_column'", :group => :parent_id).keys.size * 2
    # Set default own content box placements
    Node.all(:include => :content_representations, :conditions => "content_representations.target = 'secondary_column' AND content_representations.id IS NOT NULL").each do |node|
      rep = node.content_representations.create!(:custom_type => 'related_content', :target => 'secondary_column')
      rep.insert_at!(2)
    end if Node.count > 0
    
    Node.all(:include => :content_representations, :conditions => "content_representations.target = 'primary_column' AND content_representations.id IS NOT NULL").each do |node|
      rep = node.content_representations.create!(:custom_type => 'sub_menu', :target => 'primary_column')
      rep.insert_at!(1)
      rep = node.content_representations.create!(:custom_type => 'private_menu', :target => 'primary_column')
      rep.insert_at!(2)
    end if Node.count > 0
    
    raise "Failed, created #{ContentRepresentation.count - count} boxes. Expected #{diff}" unless ContentRepresentation.count == count + ( diff )
    
  end

  def self.down
    ContentRepresentations.delete_all("custom_type IS NOT NULL")
    
    remove_column :content_representations, :custom_type
    change_column :content_representations, :content_id, :integer, :null => false, :references => :nodes, :on_delete => :cascade
  end
end
