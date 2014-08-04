xml.instruct!

xml.tag!("sitemap:urlset", 
         "xmlns:sitemap" => "http://www.sitemaps.org/schemas/sitemap/0.9",
         "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
         "xsi:schemaLocation" => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd") do

  @changes.each do |change|
    xml.url("xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9") do
      xml.loc "/#{change.url_alias}"
      xml.lastmod change.updated_at.utc.to_s(:w3cdtfutc)

      if  (change.deleted_at.present? && (change.updated_at - change.deleted_at) < 1.0) ||
          !(change.published? && change.visible?)
        xml.action("DELETE", "xmlns" => "")
      elsif (change.updated_at - change.created_at) < 1.0
        xml.action("CREATE", "xmlns" => "")
      else
        xml.action("UPDATE", "xmlns" => "")
      end
    end
  end
end
