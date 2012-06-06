class ActiveRecord::Base
  def self.needs_editor_approval
    include NeedsEditorApproval unless self.include?(NeedsEditorApproval)
  end
end

module NeedsEditorApproval
  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
      
      attr_accessor :editor_comment
    end
  end
  
  module InstanceMethods
    def save(*args)
      options = args.extract_options!
      
      user = options[:user]
      
      user_is_editor = user && !options[:user].has_role_on?(['admin', 'final_editor'], node.new_record? ? node.parent : node)
      approval_required = options[:approval_required].blank? ? false : options[:approval_required]
      should_create_version = user_is_editor || approval_required
      
      extra_version_attributes = { :status => Version::STATUSES[:unapproved] }
      
      if user_is_editor
        extra_version_attributes.update(:editor => user, :editor_comment => self.editor_comment)
      elsif approval_required
        last_version = self.versions.last
        extra_version_attributes.update(:editor => last_version.editor, :editor_comment => last_version.editor_comment) if last_version
      end

      super(*(args << { :should_create_version => should_create_version, :extra_version_attributes => extra_version_attributes, :user => user }))
    end
    
    def update_attributes(attributes)
      user = attributes.delete(:user)
      parent = attributes[:parent]
    
      if user && parent && user.has_role_on?('editor', parent)
        attributes[:responsible_user] = user
      end

      approval_required = attributes.delete(:approval_required)
      self.attributes = attributes
      self.save(:user => user, :approval_required => approval_required)
    end
  
    def update_attributes!(attributes)
      self.update_attributes(attributes) || raise(ActiveRecord::RecordNotSaved, self.errors.full_messages.join(', '))
    end
  end
  
  module ClassMethods
    def requires_editor_approval?
      true
    end
    
    def create(attributes = {}, &block)
      if attributes.is_a?(Array)
        super(attributes, &block)
      else
        user = attributes.delete(:user)
        parent = attributes[:parent]

        if user && parent && user.has_role_on?('editor', parent)
          attributes[:responsible_user] = user
        end
        
        approval_required = attributes.delete(:approval_required)
        object = new(attributes)
        yield(object) if block_given?
        object.save(:user => user, :approval_required => approval_required)
        object
      end
    end
    
    def create!(attributes = nil, &block)
      record = self.create(attributes, &block)
      
      if record.new_record?
        raise(ActiveRecord::RecordNotSaved, record.errors.full_messages.join(', '))
      else
        record
      end
    end
  end
end