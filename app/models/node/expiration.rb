module Node::Expiration
  # Encapsulates all functionality of node concerned with the expiration of certain content.
  
  def self.included(base)
    base.class_eval do
      named_scope :expired, lambda { |*args|
        date = args.first.is_a?(Date) ? args.first : Date.today
        { :conditions => ["nodes.expires_on IS NOT NULL AND nodes.expires_on <= ? AND nodes.content_type IN (?)", date, Node.expirable_content_types] }
      }
    
      before_validation :set_default_expires_on, :if => :expiration_required?
      
      validate :expires_on_valid?, :ensure_valid_responsible_user_role, :if => lambda {|node| node.expires_on_changed? || node.content.changed? }
      if SETTLER_LOADED
        validates_presence_of :expires_on, :if => :expiration_required?
      end
      
      validates_inclusion_of :expiration_notification_method, :in => ['inherit', 'responsible_user', 'email'], :allow_blank => true
      
      before_save :empty_expires_on!, :unless => :expirable?
      
      attr_accessor :cascade_expires_on
      after_save :cascade_expires_on!, :if => :cascade_expires_on?
      
      extend(ClassMethods)
    end
  end
  
  def inherited_expiration_email_recipient
    if self.expiration_notification_method == "email" && self.expiration_email_recipient.present?
      self.expiration_email_recipient
    elsif self.expiration_notification_method == "responsible_user" && self.responsible_user.present?
      self.responsible_user
    else
      self.ancestors.first(:conditions => { :expiration_notification_method => ["email", "responsible_user"]}, :order => 'ancestry DESC').inherited_expiration_email_recipient
    end
  end
  
  def inherited_expiration_email_settings_node
    Section.first(:include => :node, :conditions => ["nodes.id IN (?) AND sections.expiration_email_subject IS NOT NULL AND sections.expiration_email_subject != ''", self.path_ids], :order => 'ancestry DESC')
  end
  
  def expiration_notification_method
    attributes['expiration_notification_method'] || 'inherit'
  end
  
  def inherited_expiration_email_subject
    inherited_expiration_email_settings_node.expiration_email_subject
  end
  
  def inherited_expiration_email_body
    inherited_expiration_email_settings_node.expiration_email_body
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

  def expiration_container?
    !!content_type_configuration[:expiration_container] 
  end

  def no_expiration_required?
    !expiration_required?
  end

  def set_default_expires_on
    self.expires_on ||= Date.today + Settler[:default_expiration_time].days
  end
  
  def expires_on_valid?
    if expirable? && expires_on.present?
      unless (Date.today..(Date.today + Settler[:default_expiration_time].days)).include?(expires_on)
        errors.add_to_base(I18n.t('nodes.expires_on_out_of_range', :date => I18n.l(Date.today + Settler[:default_expiration_time])))
      end
    end
  end
  
  def ensure_valid_responsible_user_role
    errors.add_to_base(I18n.t('acts_as_content_node.responsible_user_requires_role')) unless self.responsible_user.blank? || self.responsible_user.has_role_on?(['admin', 'editor', 'final_editor'], self)
  end
  
  def cascade_expires_on!
    self.descendants.all(:select => "DISTINCT content_type").each {|ct| ct.content_type.constantize } # FIX: until preloading is merged..
    self.descendants.update_all({:expires_on => Date.parse(cascade_expires_on)}, {:content_type => Node.expirable_content_types})
  end
  
  def cascade_expires_on?
    expiration_container? && cascade_expires_on.present?
  end
  
  def empty_expires_on!
    self.expires_on = nil
  end
      
  module ClassMethods  
    def expirable_content_types
      Node.content_types_configuration.collect {|ct, config| ct if config[:expirable] || config[:expiration_required]}.compact
    end
  end
end