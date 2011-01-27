# Main module for authentication.  
# Include this in ApplicationController to activate RoleRequirement
#
# See RoleSecurityClassMethods for some methods it provides.
module RoleRequirementSystem
  def self.included(klass)
    klass.send :class_inheritable_array, :role_requirements
    klass.send :include, RoleSecurityInstanceMethods
    klass.send :extend, RoleSecurityClassMethods
    klass.send :helper_method, :url_options_authenticate? 
    
    klass.send :role_requirements=, []
    
  end
  
  module RoleSecurityClassMethods
    
    def reset_role_requirements!
      self.role_requirements.clear
    end
    
    # Add this to the top of your controller to require a role in order to access it.
    # Checks whether user has a matching role on the current +Node+, which is expected to be in @node. To check for any node, specify :any_node => true
    # Example Usage:
    # 
    #    require_role "contractor"
    #    require_role "admin", :only => :destroy # don't allow contractors to destroy
    #    require_role "admin", :only => :update, :unless => "current_user.authorized_for_listing?(params[:id]) "
    #
    # Valid options
    #
    #  * :only - Only require the role for the given actions
    #  * :except - Require the role for everything but 
    #  * :if - a Proc or a string to evaluate.  If it evaluates to true, the role is required.
    #  * :unless - The inverse of :if
    #  * :any_node - Check whether current user has any +role+ with a matching name
    #    
    def require_role(roles, options = {})
      options.assert_valid_keys(:if, :unless,
        :for, :only, 
        :for_all_except, :except, :any_node
      )
      
      # only declare that before filter once
      unless (@before_filter_declared ||= false)
        @before_filter_declared = true
        before_filter :check_roles
      end
      
      # convert to an array if it isn't already
      roles = [roles] unless Array===roles
      
      options[:only] ||= options[:for] if options[:for]
      options[:except] ||= options[:for_all_except] if options[:for_all_except]
      
      # convert any actions into symbols
      for key in [:only, :except]
        if options.has_key?(key)
          options[key] = [options[key]] unless Array === options[key]
          options[key] = options[key].compact.collect{|v| v.to_sym}
        end 
      end
      
      self.role_requirements||=[]
      self.role_requirements << {:roles => roles, :options => options }
    end
    
    # This is the core of RoleRequirement.  Here is where it discerns if a user can access a controller or not./
    def user_authorized_for?(user, node, params = {}, binding = self.binding)
      return true unless Array===self.role_requirements
      self.role_requirements.each do | role_requirement|
        roles = role_requirement[:roles]
        options = role_requirement[:options]
        # do the options match the params?
        
        # check the action
        if options.has_key?(:only)
          next unless options[:only].include?( (params[:action]||"index").to_sym )
        end
        
        if options.has_key?(:except)
          next if options[:except].include?( (params[:action]||"index").to_sym)
        end
        
        if options.has_key?(:if)
          # execute the proc.  if the procedure returns false, we don't need to authenticate these roles
          next unless ( String===options[:if] ? eval(options[:if], binding) : options[:if].call([params,node]) )
        end
        
        if options.has_key?(:unless)
          # execute the proc.  if the procedure returns true, we don't need to authenticate these roles
          next if ( String===options[:unless] ? eval(options[:unless], binding) : options[:unless].call([params,node]) )
        end
        
        # check to see if they have one of the required roles
        passed = false

        passed = if options[:any_node]
          user.has_role?(roles)
        else
          if node.is_a?(Array)
            node.all? { |n| user.has_role_on?(roles, n) }
          else
            user.has_role_on?(roles, node)
          end
        end unless !user

        return false unless passed
      end
      
      return true
    end
  end
  
  module RoleSecurityInstanceMethods
    def self.included(klass)
      raise "Because role_requirement extends acts_as_authenticated, You must include AuthenticatedSystem first before including RoleRequirementSystem!" unless klass.included_modules.include?(AuthenticatedSystem)
    end
    
    def access_denied
      if logged_in?
        flash[:warning] = I18n.t('role_requirement_system.not_authorized')
        redirect_to root_path
      else
        super
      end
    end
    
    def check_roles       
      node = @parent_node || @node || @nodes
      
      unless self.class.user_authorized_for?(current_user, node, params, binding)
       if node && (node.is_a?(Array) ? node.any?(&:is_hidden?) : node.is_hidden?)
         raise ActionController::RoutingError, I18n.t('role_requirement_system.node_not_found')
       else
         return access_denied
       end
      end
      
      true
    end
    
  protected
    # receives a :controller, :action, and :params.  Finds the given controller and runs user_authorized_for? on it.
    # This can be called in your views, and is for advanced users only.  If you are using :if / :unless eval expressions, 
    #   then this may or may not work (eval strings use the current binding to execute, not the binding of the target 
    #   controller)
    def url_options_authenticate?(params = {})
      params = params.symbolize_keys
      if params[:controller]
        # find the controller class
        klass = eval("#{params[:controller]}_controller".classify)
      else
        klass = self.class
      end
      klass.user_authorized_for?(current_user, @parent_node || @node, params, binding)
    end
  end
end