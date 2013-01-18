xml.results do
  xml.tag!('total_count', @node_count)
  xml.nodes do
    for node in @nodes do
      xml.node do
        xml.id(node.id)
        xml.custom_url_suffix(node.custom_url_suffix)
        xml.title(node.title)
        xml.domain(node.containing_site.content.domain)
        xml.url_alias(aliased_or_delegated_address(node, :skip_custom_alias => true))
      end
    end
  end
end
