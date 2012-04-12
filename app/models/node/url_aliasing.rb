module Node::UrlAliasing
  
  MAXIMUM_URL_ALIAS_LENGTH = 255
  MAXIMUM_CURSTOM_URL_SUFFIX_LENGTH = 50

  VALID_URL_ALIAS_FORMAT = /\A[a-z0-9_\-]((\/)?[a-z0-9_\-])*\Z/i
  VALID_CUSTOM_URL_SUFFIX_FORMAT = /\A\/?[a-z0-9_\-]+\Z/i
  
  def self.included(base)
    # Scopes, validations & associations
    base.attr_protected :url_alias, :custom_url_alias
    
    # Validate url_alias. Sync regexp to routes.rb!
    base.validates_format_of :url_alias, :with => VALID_URL_ALIAS_FORMAT, :allow_nil => true
    base.validates_length_of :url_alias, :in => (2..MAXIMUM_URL_ALIAS_LENGTH), :allow_nil => true
    
    # Validate custom_url_alias. Sync regexp to routes.rb!
    base.validates_format_of :custom_url_alias, :with => VALID_URL_ALIAS_FORMAT, :allow_nil => true
    base.validates_length_of :custom_url_alias, :in => (2..MAXIMUM_URL_ALIAS_LENGTH), :allow_nil => true
    
    # Validate custom URL suffix.
    base.validates_format_of :custom_url_suffix, :with => VALID_CUSTOM_URL_SUFFIX_FORMAT, :allow_nil => true
    base.validates_length_of :custom_url_suffix, :in => (2..MAXIMUM_CURSTOM_URL_SUFFIX_LENGTH), :allow_nil => true
    
    # Do not run uniqueness validation if url_alias length exceeds MAXIMUM_URL_ALIAS_LENGTH, as this will cause
    # an ActiveRecord::StatementInvalid exception being thrown
    base.validates_uniqueness_of :url_alias, :allow_nil => true, :unless => Proc.new { |node| node.url_alias.present? && node.url_alias.length > MAXIMUM_URL_ALIAS_LENGTH }
    
    # Do not run uniqueness validation if url_alias length exceeds MAXIMUM_URL_ALIAS_LENGTH, as this will cause
    # an ActiveRecord::StatementInvalid exception being thrown
    base.validates_uniqueness_of :custom_url_alias, :allow_nil => true, :unless => Proc.new { |node| node.custom_url_alias.present? && node.custom_url_alias.length > MAXIMUM_URL_ALIAS_LENGTH }
    
    base.validate :should_not_have_reserved_url_alias
    base.validate :should_not_have_reserved_custom_url_alias
            
    # Set an URL alias
    base.before_create :set_url_alias

    # Set a custom URL alias
    base.before_update :set_custom_url_alias
    
    base.before_paranoid_delete :clear_aliases
    
    base.extend(ClassMethods)
  end
  
  # Instance Methods
  # Update after move
  def move_to_with_update_url_aliases(*args)
    self.move_to_without_update_url_aliases(*args)

    Node.sort_by_ancestry(self_and_descendants).each do |node|
      node.update_attribute(:url_alias, node.generate_unique_url_alias)
      node.update_attribute(:custom_url_alias, node.generate_unique_custom_url_alias) if node.custom_url_suffix.present?
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
    
    if containing_site != Node.root
      generated_custom_url_alias << "#{containing_site.url_alias}/"
    end

    generated_custom_url_alias << clean_for_url(self.custom_url_suffix.starts_with?('/') ? self.custom_url_suffix[1..-1] : self.custom_url_suffix)

    generated_custom_url_alias
  end
  
  def parent_url_alias
    parent.url_alias if self.parent && !self.parent.is_global_frontpage? && !self.parent.root?
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
    
      i = 0
    
      while Node.first(:conditions => [ "id <> ? AND (url_alias = ? OR custom_url_alias = ?)", (self.id || 0), temp_url_alias, temp_url_alias ]) || self.class.url_alias_reserved?(temp_url_alias)
        i += 1
        temp_url_alias = "#{generated_url_alias}-#{i}"
      end

      temp_url_alias
    end
    
    # Cleans a URL by stripping any whitespace characters, transliterating any
    # special characters, replacing illegal characters by hyphens and converting
    # the entire URL to downcase.
    def clean_for_url(url)
      result = Iconv.iconv('ascii//ignore//translit', 'utf-8', help.strip_tags(url.strip)).join.downcase.gsub(/[^\/a-z0-9]/,'-').gsub(/-{2,}/,'-').gsub(/\/$/, "")

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
    
    def clear_aliases
      self.class.update_all({ :url_alias => nil, :custom_url_alias => nil }, [ 'id IN (?)', self.subtree_ids ])
    end
      

    module ClassMethods  
      # Class methods
      # Returns if the specified URL alias has been reserved.
      def url_alias_reserved?(alias_to_check)
        return false if alias_to_check.blank?
        
        begin
          params = ActionController::Routing::Routes.recognize_path "/#{alias_to_check}"
          return !params.has_key?(:node_id)
        rescue Exception
          return false
        end
      end      
    end
end