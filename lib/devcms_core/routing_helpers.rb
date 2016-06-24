module DevcmsCore
  # This module contains various helpers to facilitate linking to
  # (content) nodes.

  module RoutingHelpers
    # Creates a link to the specified node or content,
    # using the URL alias if one is specified.
    def link_to_node(name, node_or_content, options = {}, html_options = {})
      link_to(name, aliased_or_delegated_path(node_or_content, options), html_options)
    end
    alias_method :link_to_content_node, :link_to_node

    def link_to_node_url(name, node_or_content, options = {}, html_options = {})
      link_to(name, aliased_or_delegated_url(node_or_content, options), html_options)
    end
    alias_method :link_to_content_node_url, :link_to_node_url

    # Return aliased or delegated path to node
    def aliased_or_delegated_address(node_or_content, options = {})
      type = options.delete(:type)
      node = node_or_content.is_a?(Node) ? node_or_content : node_or_content.node

      address   = "/#{node.custom_url_alias.present? ? node.custom_url_alias : node.url_alias}" unless options.delete(:skip_custom_alias)
      address ||= "/#{node.url_alias}"

      containing_node = node.containing_site
      type = :url if defined?(current_site) && current_site != containing_node

      host = options.delete(:host) || containing_node.content.domain
      if type != :path
        if defined?(request) && request.present?
          address = "#{request.protocol}#{host || request.host}:#{request.port}#{address}"
        else
          url_options = Rails.application.config.action_mailer.default_url_options || {}
          url_options[:host] = host if host
          address = URI.join(root_url(url_options), address).to_s
        end
      end

      options.delete(:action).tap { |action| address = "#{address}/#{action}" if action.present? }
      options.delete(:format).tap { |format| address = "#{address}.#{format}" if format.present? }

      address = URI.parse(address)
      address.query = options.to_query if options.present?
      address.to_s
    end

    # Return aliased or delegated path to node
    def aliased_or_delegated_path(node_or_content, options = {})
      aliased_or_delegated_address(node_or_content, options.merge(type: :path))
    end
    alias_method :content_node_path, :aliased_or_delegated_path

    # Return aliased or delegated url to node
    def aliased_or_delegated_url(node_or_content, options = {})
      aliased_or_delegated_address(node_or_content, options.merge(type: :url))
    end
    alias_method :content_node_url, :aliased_or_delegated_url

    # Like url_for, but for nodes
    def node_url_for node_or_content, options = {}
      url_options = {}
      url_options[:action] = options[:path] if options[:path].present?

      options.except(:action, :controller, :id, :commit, :utf8, :path, :only_path).each do |key, value|
        url_options[key] = value if value.present?
      end

      if options[:only_path].nil? || options[:only_path]
        aliased_or_delegated_address(node_or_content, url_options)
      else
        aliased_or_delegated_url(node_or_content, url_options)
      end
    end

    # Return absolute link to the root site
    def root_site_url(relative_link)
      @root_site ||= Node.root.content
      URI.join("#{request.protocol}#{@root_site.domain}:#{request.port}", relative_link).to_s
    end
  end
end
