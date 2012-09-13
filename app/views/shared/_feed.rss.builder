url = local_assigns[:url] || content_node_url(local_assigns[:content_node].try(:node), :format => 'rss')
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", :'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title local_assigns[:title] || local_assigns[:content_node].title
    [:description, :body].find do |attribute|
      local_assigns[:content_node].respond_to?(attribute)
    end.try do |attribute|
      xml.description strip_tags(local_assigns[:content_node].send(attribute))
    end
    xml.link url
    xml.lastBuildDate (items.first.try(:created_at) || Time.now.utc).to_s(:rfc822)
    xml.tag!(:'atom:link', :rel => 'self', :type => "application/rss+xml",  :href => url)

    items.each do |item|
      xml.item do
        xml.title item.title
        [:description, :preamble, :comment, :body].find do |attribute|
          item.respond_to?(attribute)
        end.try do |attribute|
          xml.description strip_tags(item.send(attribute))
        end
        xml.pubDate item.created_at.to_s(:rfc822)
        xml.link content_node_url(item.node)
        xml.guid content_node_url(item.node)
      end
    end
  end
end
