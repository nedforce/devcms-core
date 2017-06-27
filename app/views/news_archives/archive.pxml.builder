xml.news_archive type: 'NEWSARCHIVE' do |news_archive|
  @news_items.each do |news_item|
    news_archive.news_item do |item|
      item.title news_item.title
      item.preamble news_item.preamble
      item.body news_item.body
      item.published_at news_item.node.publication_start_date
      item.created_at news_item.created_at
      item.updated_at news_item.updated_at
      item.images do |images|
        news_item.node.children.accessible.with_content_type('Image').map do |node|
          content_node_url(node) if !node.content.is_for_header? && node.content.show_in_listing
        end.compact
      end
      item.attachments do |attachments|
        news_item.node.children.accessible.with_content_type('Attachment').map do |node|
          [ node.content.title, node.content.extension, content_node_url(node, format: node.content.extension)]
        end
      end
    end
  end
end
