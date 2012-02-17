module RoutingExtensions

  # This module defines several extensions to ActionController::Routing::RouteSet.
  # These extensions allow delegation and URL aliasing to take place by modifying
  # the behaviour of the original path recognition methods.

  module RouteSetExtensions

    # Override default path recognition method by our own through aliasing
    def self.included(base)
      base.alias_method_chain :extract_request_environment, :domain_extraction
      base.alias_method_chain :recognize_path, :delegation_or_url_aliasing
    end

    def extract_request_environment_with_domain_extraction(request)
      parts = request.host.split('.')
      parts.shift if parts.first == 'www'
      extract_request_environment_without_domain_extraction(request).merge({ :domain => parts.join('.') })
    end

    def recognize_path_with_delegation_or_url_aliasing(path, environment = {})
      # First we determine the Site node for the given domain
      site = Site.find_by_domain(environment[:domain]) || raise(ActionController::RoutingError, 'No site found!')
    
      begin
        # Use Rails' default path parsing
        params = recognize_path_without_delegation_or_url_aliasing(path, environment).merge({ :site_id => site.node.id })
        controller = params[:controller]
        
        # What we do next depends on the 'controller'
        # If its name starts with '_' we have a psuedo-controller
        if controller.starts_with?('_')
          case controller
          # Delegation to root
          when '_delegated_root' then
            node = site.node
          # Delegation to a content node
          when '_delegated' then
            node = Node.find(params[:id])
          # Delegation to an aliased content node
          else
            url_alias = params[:id]
      
            unless node = Node.first(:conditions => [ 'url_alias = ? OR custom_url_alias = ?', url_alias, url_alias ])
              parts           = url_alias.split('/')
              params[:action] = parts.pop
              url_alias       = parts.join('/')
              node            = Node.first(:conditions => [ 'url_alias = ? OR custom_url_alias = ?', url_alias, url_alias ])
            end
          
            node || raise(ActionController::RoutingError, "Invalid alias #{url_alias} specified for path #{path}")
          end
        
          # Node might point to a different node
          node = update_to_referenced_node(node)
        
          params.update({ 
            :id => node.content_id,
            :node_id => node.id,
            :controller => node.content_type.tableize
          })
        # We have a 'real' controller
        else
          if params[:id]
            klass = controller.classify.split('::').last.constantize rescue nil
          
            if klass && klass.respond_to?(:is_content_node?)
              if params[:id].to_i.to_s == params[:id]
                node = Node.first(:conditions => [ 'content_type = ? AND content_id = ?', klass.base_class.name, params[:id] ]) || raise(ActionController::RoutingError, 'Invalid content node specified')
              else
                raise ActionController::RoutingError, "Invalid path specified: #{path}"
              end
            elsif klass.nil? || klass == Node
              node = Node.find(params[:id])
            end

            if node.present?
              if controller.starts_with?('admin')
                params[:node_id] = node.id
              else
                # Node might point to a different node
                node = update_to_referenced_node(node)

                params.update({ 
                  :id => node.content_id,
                  :node_id => node.id,
                  :controller => node.content_type.tableize
                })
              end
            end
          end
        end
      rescue ActionController::RoutingError, ActiveRecord::RecordNotFound => e
        raise e if Rails.env.development?
        params = { :controller => :errors, :action => :error_404, :site_id => site.node.id }
      end
      
      params.inject({}) do |hash, (key, value)|
        hash[key] = value.to_s
        hash
      end
    end

    def update_to_referenced_node(node)
      case node.content_type
      when 'ContentCopy'
        node = update_to_referenced_node(node.content.copied_node)
      when 'Section'
        if frontpage_node = node.content.frontpage_node
          node = update_to_referenced_node(frontpage_node)
        end
      end
      
      node
    end
  end
end
