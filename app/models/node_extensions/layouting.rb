module NodeExtensions::Layouting
  extend ActiveSupport::Concern    
    
  included do
    # Scopes, validations & associations
    
    has_many :sections, :foreign_key => :frontpage_node_id
    validate :should_not_hide_global_frontpage
    
    has_many :content_representations, :dependent => :destroy, :foreign_key => :parent_id, :order => :position
    has_many :representations,         :dependent => :destroy, :class_name => 'ContentRepresentation', :foreign_key => :content_id
    
    serialize :layout_configuration, Hash
    
    before_create :set_default_layout
  end

  module ClassMethods  
    # Class methods
    # Returns the global frontpage node.
    def global_frontpage
      root = Node.root
      root.content.has_frontpage? ? root.content.frontpage_node : root
    end
  end
  
  # [Rails3] Serialized attributes may return an internal object. Should be fixed in 3.2.4.
  def layout_configuration
    value = super
    if value && value.respond_to?(:unserialized_value)
      return value.unserialized_value
    else
      return value
    end
  end

  # The inherited layout.
  def own_or_inherited_layout
    Layout.find(layout) || inherited_layout
  end
  
  def inherited_layout
    if parent
      return parent.own_or_inherited_layout
    else
      raise "node has no parent to inherit layout from"
    end
  end
  
  def own_or_inherited_layout_variant
    if layout_variant.present?
      own_or_inherited_layout.find_variant(self.layout_variant)
    else 
      inherited_layout_variant
    end
  end
  
  # Find the inherited layout, fall back to default if it is not inheritable
  def inherited_layout_variant
    if self.parent
      var = parent.own_or_inherited_layout_variant
      return var['inheritable'] ? var : own_or_inherited_layout.find_variant('default')
    else
      raise "node has no parent to inherit layout from"
    end
  end
  
  # Remove all layout elements and settings for this node
  def reset_layout
    content_representations.clear
    update_attributes(:layout => nil, :layout_configuration => nil, :layout_variant => nil)
  end
  
  # Update and save the layout condiguration given as node attributes
  # TODO: Refactor to use setters and a writer for the representations
  def update_layout(layout_config = {})
    without_search_reindex do
      # Delete any empty settings from the configuration and save everything
      layout_config[:node][:layout_configuration].delete_if { |k,v| v.blank? } unless layout_config[:node][:layout_configuration].blank?
      
      return false unless update_attributes(layout_config[:node])
      
      # Find the layout and variant used to set the representations
      layout  = Layout.find(layout_config[:node][:layout]) || inherited_layout
      variant = layout.find_variant(layout_config[:node][:layout_variant]) || inherited_layout_variant

      # Remove representations for variant that don't exist for this layout variant
      content_representations.where('target NOT IN (?)', layout_config[:targets].keys).destroy_all

      # Remove any moved or removed representations
      layout_config[:targets].each do |target, content_ids|
        content_ids = content_ids.select { |cid| cid.present? }
        # Destroy removed representations
        if content_ids.empty?
          content_representations.where("content_representations.target = ?", target).destroy_all
        else
          custom_types = content_ids.select { |ci| ci.to_i.to_s != ci }
          content_ids  = content_ids.select { |ci| ci.to_i.to_s == ci }
          content_representations.where("target = :target AND ((content_id IS NOT NULL AND ((:content_ids) IS NULL OR content_id NOT IN (:content_ids))) OR (custom_type IS NOT NULL AND ((:custom_types) IS NULL OR custom_type NOT IN (:custom_types))))", {:target => target, :content_ids => content_ids, :custom_types => custom_types}).destroy_all
        end
      end

      # Move or create representations for each target
      layout_config[:targets].each do |target, content_ids|
        content_ids = content_ids.select { |cid| cid.present? }          
        if variant[target].try(:[], 'main_content') && self.content_type == 'Section'
          content.update_attributes(:frontpage_node_id => content_ids.first.blank? ? nil : content_ids.first)
        else
          content_ids.each_with_index do |content_id, i|
            # Check wether this is a custom rep. or a normal content representation and handle accordingly
            if content_id.to_i.to_s != content_id
              representation = content_representations.where("content_representations.target = ? AND content_representations.custom_type = ?", target, content_id).first
              if representation.present?
                representation.update_attributes!(:position => i+1)
              else
                content_representations.create!(:custom_type => content_id, :target => target, :position => i+1)
              end
            else
              representation = content_representations.where("content_representations.target = ? AND content_representations.content_id = ?", target, content_id).first
              if representation.present?
                representation.update_attributes!(:position => i+1)
              else
                content_representations.create!(:content => Node.find(content_id), :target => target, :position => i+1)
              end
            end
          end
        end
      end
    end
  end
  
  # Merges parent layout config with own layout config
  def own_or_inherited_layout_configuration
    config = parent.own_or_inherited_layout_configuration unless root? || content_class == Site
    config ||= {}
    config.merge(layout_configuration || {})
  end
  
  
  # Retrieve content representations for a given target
  # Can inherit from parent node (defaults to true)
  def find_content_representations(target, inherit = true)
    # Do not inherit if this node is a Site node, as this is undesirable
    conditions = {}
    conditions.update(:target => target) if target
    
    if !content_representations.exists?(conditions) && inherit && parent && content_class != Site
      parent.find_content_representations(target, inherit) 
    else
      content_representations.where(conditions).includes(:content)
    end
  end
  
  # Find header image(s) for this node, either those set on this node or on one of its parents.
  def header_images
    Image.accessible.where(:is_for_header => true, 'nodes.ancestry' => self.header_container_ancestry)
  end

  # Find the ancestry for the first parent or self containing header images
  # use containing site if none are found in the contaning site
  def header_container_ancestry
    ancestries = []
    path_ids.reduce([]) do |last_path, parent_id|
      ancestries << last_path.push(parent_id).join("/")
      last_path
    end
    container_ancestry = Image.includes(:node).where("is_for_header = ? and nodes.ancestry IN (?)", true, ancestries).group('nodes.ancestry').count.keys.last
    if container_ancestry.present? && container_ancestry != Node.root.id.to_s
      container_ancestry
    else
      containing_site.child_ancestry
    end
  end

  def header_container
    Node.find(header_container_ancestry.split("/").last)
  end

  # Returns a random header image for this node.
  def random_header_image
    header_images.sample
  end
  
  # Returns true if this node is a frontpage, false otherwise.
  def is_frontpage?
    sections.any?
  end

  # Returns true if this node is the global front page, false otherwise.
  def is_global_frontpage?
    self == Node.global_frontpage
  end

  # Returns true if this node is an ancestor of the global frontpage node.
  def contains_global_frontpage?
    Node.global_frontpage.is_descendant_of?(self)
  end
  
  protected

  # Prevents a +Node+ from being hidden if it is, or contains the +global+ frontpage.
  def should_not_hide_global_frontpage
    errors.add(:base, :cant_hide_frontpage) if (private? || hidden?) && (is_global_frontpage? || contains_global_frontpage?)
  end
  
  def set_default_layout
    if sub_content_type == 'Site'
      self.layout = Node.roots.present? ? Node.root.layout : 'default'
      self.layout_variant = 'default'
      self.layout_configuration = {}
    end
  end

end