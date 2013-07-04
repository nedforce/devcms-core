module NodeExtensions::UrlAliasing
  extend ActiveSupport::Concern    
  
  MAXIMUM_URL_ALIAS_LENGTH = 255
  MAXIMUM_CURSTOM_URL_SUFFIX_LENGTH = 50

  VALID_URL_ALIAS_FORMAT = /\A[a-z0-9_\-]((\/)?[a-z0-9_\-])*\Z/i
  VALID_CUSTOM_URL_SUFFIX_FORMAT = /\A\/?[a-z0-9_\-]+\Z/i
  
  included do
    # Scopes, validations & associations
    attr_protected :url_alias, :custom_url_alias
    
    # Validate url_alias. Sync regexp to routes.rb!
    validates_format_of :url_alias, :with => VALID_URL_ALIAS_FORMAT, :allow_nil => true
    validates_length_of :url_alias, :in => (2..MAXIMUM_URL_ALIAS_LENGTH), :allow_nil => true
    
    # Validate custom_url_alias. Sync regexp to routes.rb!
    validates_format_of :custom_url_alias, :with => VALID_URL_ALIAS_FORMAT, :allow_nil => true
    validates_length_of :custom_url_alias, :in => (2..MAXIMUM_URL_ALIAS_LENGTH), :allow_nil => true
    
    # Validate custom URL suffix.
    validates_format_of :custom_url_suffix, :with => VALID_CUSTOM_URL_SUFFIX_FORMAT, :allow_nil => true
    validates_length_of :custom_url_suffix, :in => (2..MAXIMUM_CURSTOM_URL_SUFFIX_LENGTH), :allow_nil => true
    
    # Do not run uniqueness validation if url_alias length exceeds MAXIMUM_URL_ALIAS_LENGTH, as this will cause
    # an ActiveRecord::StatementInvalid exception being thrown
    # validates_uniqueness_of :url_alias, :allow_nil => true, :unless => Proc.new { |node| node.url_alias.present? && node.url_alias.length > MAXIMUM_URL_ALIAS_LENGTH }
    
    # Do not run uniqueness validation if url_alias length exceeds MAXIMUM_URL_ALIAS_LENGTH, as this will cause
    # an ActiveRecord::StatementInvalid exception being thrown
    # validates_uniqueness_of :custom_url_alias, :allow_nil => true, :unless => Proc.new { |node| node.custom_url_alias.present? && node.custom_url_alias.length > MAXIMUM_URL_ALIAS_LENGTH }
    
    validate :should_not_have_reserved_url_alias
    validate :should_not_have_reserved_custom_url_alias
    validate :should_have_unique_url_alias_in_site
    validate :should_have_unique_custom_url_alias_in_site
            
    # Set an URL alias
    before_create :set_url_alias

    # Set a custom URL alias
    before_update :set_custom_url_alias
    
    before_paranoid_delete :clear_aliases

  end

  module ClassMethods  
    # Class methods
    # Returns if the specified URL alias has been reserved.
    def url_alias_reserved?(alias_to_check)
      if alias_to_check.blank?
        false 
      elsif Rails.application.config.reserved_slugs.include?(alias_to_check)
        true
      else
        begin
          Rails.application.routes.recognize_path "/#{alias_to_check.split('/').first}"
          return true
        rescue ActionController::RoutingError
          return false
        end
      end
    end
    
    # Helper method for constructing a content url path for a node, used for rewrites
    def path_for_node(node, action = '', format = '', query = '') 
      case
      when node.content_type == 'ContentCopy'
        Node.path_for_node(node.content.copied_node, action, format, query)
      when node.content_type == 'Section' && frontpage_node = node.content.frontpage_node
        Node.path_for_node(frontpage_node, action, format, query)
      when DevcmsCore::Engine.content_type_configuration(node.content_type)[:nested_resource]
        path_builder = lambda do |node|
          if DevcmsCore::Engine.content_type_configuration(node.content_type)[:nested_resource]
            path_builder.call(node.parent) + "/#{node.content_type.tableize}/#{node.content_id}"  
          else
            "/#{node.content_type.tableize}/#{node.content_id}"  
          end
        end

        "#{path_builder.call(node)}#{action}#{format}#{query}"
      else
        "/#{node.content_type.tableize}/#{node.content_id}#{action}#{format}#{query}"      
      end
    end
    
    def find_node_for_url_alias!(url_alias, site)
      find_node_for_url_alias(url_alias, site) || raise(ActiveRecord::RecordNotFound)
    end
    
    def find_node_for_url_alias(url_alias, site)
      slugs = []
      url_alias.split('/').each do |part|
        if slugs.empty?
          slugs = ["#{part.downcase}"]
        else
          slugs << "#{slugs.last}/#{part.downcase}"
        end
      end

      # Exclude other sites if the site is the root node.
      if site.node.root?
        nodes_to_exclude_for_root = site.node.children.with_content_type('Site')
        site.node.subtree.where([ 'url_alias IN (:slugs) OR custom_url_alias IN (:slugs)', { :slugs => slugs }]).exclude_subtrees_of(nodes_to_exclude_for_root).reorder('url_alias DESC').first
      else
        site.node.subtree.where([ 'url_alias IN (:slugs) OR custom_url_alias IN (:slugs)', { :slugs => slugs }]).reorder('url_alias DESC').first
      end
    end

  end

  # Instance Methods
  # Update after move
  def move_to_with_update_url_aliases(*args)
    self.move_to_without_update_url_aliases(*args)
    update_subtree_url_aliases
  end

  def update_subtree_url_aliases
    Node.sort_by_ancestry(self_and_descendants).each do |node|
      node.update_column(:url_alias, node.generate_unique_url_alias)
      node.update_column(:custom_url_alias, node.generate_unique_custom_url_alias) if node.custom_url_suffix.present?
    end
  end
  
  # Generates an URL alias based on the ancestors of this node and a path
  # specified by its content node.
  def generate_url_alias
    generated_url_alias = ""

    if parent_url_alias
      generated_url_alias << "#{parent_url_alias}/"
    end

    generated_url_alias << clean_for_url(self.content.path_for_url_alias(self))

    generated_url_alias
  end
  
  # Generates a custom URL alias based on the ancestors of this node and a path
  # specified by its content node.
  def generate_custom_url_alias
    generated_custom_url_alias = ""

    if !self.custom_url_suffix.starts_with?('/') && parent_url_alias
      generated_custom_url_alias << "#{parent_url_alias}/"
    end
    
    generated_custom_url_alias << clean_for_url(self.custom_url_suffix.starts_with?('/') ? self.custom_url_suffix[1..-1] : self.custom_url_suffix)

    generated_custom_url_alias
  end
  
  def parent_url_alias
    parent.url_alias if self.parent && !self.parent.is_global_frontpage? && !self.parent.root? && self.parent.sub_content_type != "Site"
  end
  
  def generate_unique_url_alias
    uniqify_url_alias(self.generate_url_alias[0..(MAXIMUM_URL_ALIAS_LENGTH - 6)])
  end

  def generate_unique_custom_url_alias
    uniqify_url_alias(self.generate_custom_url_alias[0..(MAXIMUM_URL_ALIAS_LENGTH - 6)])
  end
  
  # Sets an URL alias if none has been specified on create or +force+ is true.
  def set_url_alias(force = false)
    self.url_alias = generate_unique_url_alias if self.url_alias.blank? || force
  end

  protected

  def set_custom_url_alias
    self.custom_url_alias = (self.custom_url_suffix.present? ? self.generate_unique_custom_url_alias : nil) if custom_url_suffix_changed?
  end

  def uniqify_url_alias(generated_url_alias)
    temp_url_alias = generated_url_alias

    unless is_root?
      i = 0
      while containing_site.subtree.exclude_subtrees_of(nodes_to_exclude).first(:conditions => [ "id <> ? AND (url_alias = ? OR custom_url_alias = ?)", (id || 0), temp_url_alias, temp_url_alias ]) || self.class.url_alias_reserved?(temp_url_alias)
        i += 1
        temp_url_alias = "#{generated_url_alias}-#{i}"
      end
    end

    temp_url_alias
  end

  # Cleans a URL by stripping any whitespace characters, transliterating any
  # special characters, replacing illegal characters by hyphens and converting
  # the entire URL to downcase.
  def clean_for_url(url)
    result = Node::Helper.instance.strip_tags(url.strip).encode('utf-8', :ignore => true, :translit => true).downcase.gsub(/[^\/a-z0-9]/,'-').gsub(/-{2,}/,'-').gsub(/\/$/, "")

    # remove any leading and trailing hyphens, also when directly after a slash
    result = $1 while result =~ /\A-(.*)/
    result = $1 while result =~ /(.*)-\z/
    result.gsub!(/\/-/, '/')
    return result
  end

  # Prevents saving this node when the URL alias contains reserved words.
  def should_not_have_reserved_url_alias
    errors.add(:url_alias, :reserved_url_alias) if self.class.url_alias_reserved?(self.url_alias)
  end

  # Prevents saving this node when the URL alias contains reserved words.
  def should_not_have_reserved_custom_url_alias
    errors.add(:url_alias, :reserved_custom_url_alias) if self.class.url_alias_reserved?(self.custom_url_alias)
  end
  
  def should_have_unique_url_alias_in_site
    if url_alias.present? && url_alias.size <= MAXIMUM_URL_ALIAS_LENGTH
      errors.add(:url_alias, :taken) if containing_site.self_and_descendants.exclude_subtrees_of(nodes_to_exclude).where(["url_alias = ? AND id != ?", url_alias, (id || 0)]).any?
    end
  end

  def should_have_unique_custom_url_alias_in_site
    if custom_url_alias.present? && custom_url_alias.size <= MAXIMUM_URL_ALIAS_LENGTH
      errors.add(:custom_url_alias, :taken) if containing_site.self_and_descendants.exclude_subtrees_of(nodes_to_exclude).where(["custom_url_alias = ? AND id != ?", custom_url_alias, (id || 0)]).any?
    end
  end

  def clear_aliases
    self.class.update_all({ :url_alias => nil, :custom_url_alias => nil }, [ 'id IN (?)', self.subtree_ids ])
  end

  def nodes_to_exclude
    containing_site.root? ? containing_site.children.with_content_type('Site') : nil
  end

end