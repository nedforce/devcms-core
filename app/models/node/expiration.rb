module Node::Expiration
  
  # Encapsulates all functionality of node concerned with the expiration of certain content.
  
  def self.included(base)
    base.named_scope :expired, lambda { |*args|
      date = args.first.is_a?(Date) ? args.first : Date.today
      { :conditions => ["nodes.expires_on IS NOT NULL AND nodes.expires_on <= ? AND nodes.content_type IN (?)", date, Node.expirable_content_types] }
    }
    if SETTLER_LOADED
      base.validates_presence_of :expires_on, :if => :expiration_required?
      base.validates_inclusion_of :expires_on, :in => Date.today..(Date.today + Settler[:default_expiration_time].days), :allow_blank? => :no_expiration_required?, :if => :expirable?
    end
    
    base.before_validation :set_default_expires_on, :if => :expiration_required?
    
    base.extend(ClassMethods)
  end
  
  def expired?
    expirable? && expires_on.present? && expires_on <= Date.today
  end
  
  def expirable?
    !!content_type_configuration[:expirable] || expiration_required?
  end
  
  def expiration_required?
    !!content_type_configuration[:expiration_required] 
  end
  
  def no_expiration_required?
    !expiration_required?
  end
  
  def set_default_expires_on
    self.expires_on ||= Date.today + Settler[:default_expiration_time].days
  end
  
  module ClassMethods  
    def expirable_content_types
      Node.content_types_configuration.collect {|ct, config| ct if config[:expirable] || config[:expiration_required]}.compact
    end
  end
end