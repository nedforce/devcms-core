# This module contains various helperst to facilitate linking to (content) nodes.
module ActionView #:nodoc:
  module Helpers #:nodoc:
    module RoutingHelpers

      # Creates a link to the specified node.
      def link_to_node_delegated(name, node, options = {}, html_options = nil)
        link_to(name, delegated_path(options.merge({ :id => node.to_param })), html_options)
      end
      
      # Creates a link to the specified node using the URL alias.
      def link_to_node_aliased(name, node, options = {}, html_options = nil)
        raise(ActionView::ActionViewError, 'Specified node has no URL alias!') if node.url_alias.blank?
        link_to(name, aliased_path(options.merge({ :id => node.url_alias })), html_options).gsub(/%2F/, '/')
      end
      
      # Creates a link to the specified node, using the URL alias if one is specified.
      def link_to_node(name, node, options = {}, html_options = {})
        link_to(name, aliased_or_delegated_path(node, options), html_options)
      end
      
      # Creates a link to the specified content node.
      def link_to_content_node_delegated(name, content_node, options = {}, html_options = nil)
        link_to_node_delegated(name, content_node.node, options, html_options)
      end
      
      # Creates a link to the specified content node using the URL alias.
      def link_to_content_node_aliased(name, content_node, options = {}, html_options = nil)
        link_to_node_aliased(name, content_node.node, options, html_options)
      end
      
      # Creates a link to the specified content node, using the URL alias if one is specified.
      def link_to_content_node(name, content_node, options = {}, html_options = nil)
        link_to_node(name, content_node.node, options, html_options)
      end
      
      # return aliased or delegated path to node
      def aliased_or_delegated_address(node, options = {})
        type = (options.delete(:type) || :path).to_s
        unless node.url_alias.blank?
          # gsub %2F to / to create "real paths"
          send("aliased_#{type}", options.merge({ :id => node.url_alias })).gsub(/%2F/, '/').gsub(/\?format=/, '.')
        else
          send("delegated_#{type}", options.merge({ :id => node.to_param }))
        end
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
end
