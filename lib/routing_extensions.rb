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
      if site = Site.find_by_domain(environment[:domain] || '').node
        params = recognize_path_without_delegation_or_url_aliasing(path, environment)
        params.update(:site_node_id => site.id )
        case params[:controller]
        when '_delegated_root' then
          node = site
        when '_delegated' then
          node_id = params.delete(:id).to_i
          node    = site.subtree.find(node_id)
        when '_aliased' then
          url_alias = params.delete(:id)
          unless node = site.subtree.first(:conditions => [ 'url_alias = ? OR custom_url_alias = ?', url_alias, url_alias ])
            parts           = url_alias.split('/')
            params[:action] = parts.pop
            url_alias       = parts.join('/')
            node            = site.subtree.first(:conditions => [ 'url_alias = ? OR custom_url_alias = ?', url_alias, url_alias ])
          end
        else
          no_node_required = true
        end

        unless no_node_required
          if node.present?
            node = update_to_referenced_node(node)
            controller = node.content_class.name.tableize
            @first_try = true

            begin
              # First try with the own controller. If that
              # fails, try with the parent class' controller.
              if @first_try
                "#{controller}_controller".camelize.constantize
              else
                controller = node.content_type.tableize
                "#{controller}_controller".camelize.constantize
              end
            rescue
              if @first_try
                @first_try = false
                retry
              else
                raise ActionController::RoutingError, "No route matches #{path.inspect} with #{environment.inspect}"
              end
            end

            params.update(:controller => controller, :id => node.content_id, :node_id => node.id)
          else
            raise ActionController::RoutingError, "No route matches #{path.inspect} with #{environment.inspect}"
          end
        end

        return params
      else
        raise ActionController::RoutingError, 'No site found'
      end
    end

    def update_to_referenced_node(node)
      case node.content_type
      when 'ContentCopy' then
        node = update_to_referenced_node(node.content.copied_node)
      when 'Section' then
        if frontpage_node = node.content.frontpage_node
          node = update_to_referenced_node(frontpage_node)
        end
      end
      return node
    end
  end
end
