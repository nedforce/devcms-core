module Node::Layouting

  def self.included(base)
    # Scopes, validations & associations

    base.has_many :sections, :foreign_key => :frontpage_node_id
    base.validate :should_not_hide_global_frontpage

    base.has_many :content_representations, :dependent => :destroy, :foreign_key => :parent_id, :order => :position
    base.has_many :representations,         :dependent => :destroy, :class_name => 'ContentRepresentation', :foreign_key => :content_id

    base.serialize :layout_configuration

    base.before_create :set_default_layout

    base.extend(ClassMethods)
  end

  def layout_configuration
    self.attributes["layout_configuration"] || {}
  end

  # The inherited layout.
  def own_or_inherited_layout
    Layout.find(self.layout) || self.inherited_layout
  end

  def inherited_layout
    if self.parent
      return self.parent.own_or_inherited_layout
    else
      raise "node has no parent to inherit layout from"
    end
  end

  def own_or_inherited_layout_variant
    if self.layout_variant.present?
      self.own_or_inherited_layout.find_variant(self.layout_variant)
    else 
      self.inherited_layout_variant
    end
  end

  # Find the inherited layout, fall back to default if it is not inheritable
  def inherited_layout_variant
    if self.parent
      var = self.parent.own_or_inherited_layout_variant
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
      layout  = Layout.find(layout_config[:node][:layout]) || self.inherited_layout
      variant = layout.find_variant(layout_config[:node][:layout_variant]) || self.inherited_layout_variant

      # Remove any moved or removed representations
      layout_config[:targets].each do |target, content_ids|
        content_ids = content_ids.select { |cid| cid.present? }
        # Destroy removed representations
        if content_ids.empty?
          self.content_representations.all(:conditions => ["content_representations.target = ? ", target]).each { |cr| cr.destroy }
        else
          custom_types = content_ids.select { |ci| ci.to_i.to_s != ci }
          content_ids  = content_ids.select { |ci| ci.to_i.to_s == ci }
          self.content_representations.all(:conditions => ["target = :target AND ((content_id IS NOT NULL AND ((:content_ids) IS NULL OR content_id NOT IN (:content_ids))) OR (custom_type IS NOT NULL AND ((:custom_types) IS NULL OR custom_type NOT IN (:custom_types))))", { :target => target, :content_ids => content_ids, :custom_types => custom_types }]).each { |cr| cr.destroy }
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
              representation = self.content_representations.first(:conditions => ["content_representations.target = ? AND content_representations.custom_type = ?", target, content_id])
              if representation.present?
                representation.update_attributes!(:position => i+1)
              else
                self.content_representations.create!(:custom_type => content_id, :target => target, :position => i+1)
              end
            else
              representation = self.content_representations.first(:conditions => ["content_representations.target = ? AND content_representations.content_id = ?", target, content_id])
              if representation.present?
                representation.update_attributes!(:position => i+1)
              else
                self.content_representations.create!(:content => Node.find(content_id), :target => target, :position => i+1)
              end
            end
          end
        end
      end
    end
  end
  
  # Merges parent layout config with own layout config
  def own_or_inherited_layout_configuration
    config = parent.own_or_inherited_layout_configuration unless self.root? || self.content_class == Site
    config ||= {}
    config.merge(self.layout_configuration || {})
  end
  
  
  # Retrieve content representations for a given target
  # Can inherit from parent node (defaults to true)
  def find_content_representations(target, inherit = true)
    # Do not inherit if this node is a Site node, as this is undesirable
    conditions = {}
    conditions.update(:target => target) if target
    
    if !self.content_representations.exists?(conditions) && inherit && self.parent && self.content_class != Site
      self.parent.find_content_representations(target, inherit) 
    else
      self.content_representations.all(:conditions => conditions, :include => :content)
    end
  end
  
  # Find header image(s) for this node, either those set on this node or on one of its parents.
  def header_images
    images = Image.accessible.all(:conditions => { :is_for_header => true, 'nodes.ancestry' => self.child_ancestry })
  
    if images.empty? && !self.root?
      images = self.parent.header_images
    end

    images
  end

  # Returns a random header image for this node.
  def random_header_image
    self.header_images.sample
  end
  
  # Returns true if this node is a frontpage, false otherwise.
  def is_frontpage?
    self.sections.any?
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
    errors.add_to_base(:cant_hide_frontpage) if (self.private? || self.hidden?) && (self.is_global_frontpage? || self.contains_global_frontpage?)
  end
  
  def set_default_layout
    if self.sub_content_type == 'Site'
      self.layout = Node.roots.present? ? Node.root.layout : 'default'
      self.layout_variant = 'default'
      self.layout_configuration = {}
    end
  end

  module ClassMethods  
    # Class methods
    # Returns the global frontpage node.
    def global_frontpage
      root = Node.root
      root.content.has_frontpage? ? root.content.frontpage_node : root
    end
  end
end