# This class adds facet search supports to GoogleSiteSearch::Search from the
# google_site_search gem.
#
module GoogleSiteSearch
  class FacetSearch < Search

    attr_reader :facets

    protected

    def parse_xml
      super

      begin
        doc = ::XML::Parser.string(@xml).parse
        @facets = doc.find('//Context/Facet/FacetItem').map do |facet_item|
          facet_item.children.map do |child|
            [child.name, child.content]
          end.to_h
        end
        @facets ||= []
      rescue Exception => e
        raise ParsingError, "#{e.message} Class:[#{e.class}] URL:[#{@url}] XML:[#{@xml}]"
      end
    end

  end
end
