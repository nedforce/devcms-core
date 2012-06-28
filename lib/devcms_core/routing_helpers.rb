module DevcmsCore
  # This module contains various helperst to facilitate linking to (content) nodes.
  module RoutingHelpers
  
    # Creates a link to the specified node, using the URL alias if one is specified.
    def link_to_node(name, node, options = {}, html_options = {})
      link_to(name, aliased_or_delegated_path(node, options), html_options)
    end

    # Creates a link to the specified content node, using the URL alias if one is specified.
    def link_to_content_node(name, content_node, options = {}, html_options = nil)
      link_to_node(name, content_node.node, options, html_options)
    end
  
    # return aliased or delegated path to node
    def aliased_or_delegated_address(node, options = {})
      type = (options.delete(:type) || :path).to_s
      
      address = "/#{node.custom_url_alias.present? ? node.custom_url_alias : node.url_alias}"
      unless type == :path
        host = options.delete(:host)
        if defined?(request) && request.present?
          address = "#{request.protocol}#{host || request.host_with_port}#{address}" 
        else
          url_options = Rails.application.config.action_mailer.default_url_options || {}
          url_options.merge!(:host => host) if host
          address = URI.join(root_url(url_options), address).to_s
        end
      end

      options.delete(:action).tap{|action| address = "#{address}/#{action}" if action.present? }      
      options.delete(:format).tap{|format| address = "#{address}.#{format}" if format.present? }

      address = URI.parse(address)
      address.query = options.to_query if options.present?
      address.to_s
    end
  
    # return aliased or delegated path to node
    def aliased_or_delegated_path(node, options = {})
      aliased_or_delegated_address(node, options)
    end
  
    # content_node_path is a convenient alias for aliased_or_delegated_path
    alias_method :content_node_path, :aliased_or_delegated_path
  
    # return aliased or delegated url to node
    def aliased_or_delegated_url(node, options = {})
      aliased_or_delegated_address(node, options.merge(:type => :url))
    end
    # content_node_path is a convenient alias for aliased_or_delegated_url
    alias_method :content_node_url, :aliased_or_delegated_url
  
  end
end