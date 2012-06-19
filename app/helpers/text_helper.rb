require "rexml/parsers/pullparser"

module TextHelper

  def truncate_html(input, len = 30, extension = "...")
    p = REXML::Parsers::PullParser.new(input)
      tags    = []
      new_len = len
      results = ''
      while p.has_next? && new_len > 0
        p_e = p.pull
        case p_e.event_type
      when :start_element
        tags.push p_e[0]
        results << "<#{tags.last} #{attrs_to_s(p_e[1])}>"
      when :end_element
        results << "</#{tags.pop}>"
      when :text
        results << p_e[0].first(new_len)
        new_len -= p_e[0].length
      else
        results << "<!-- #{p_e.inspect} -->"
      end
    end

    tags.reverse.each do |tag|
      results << "</#{tag}>"
    end

    raw (results.to_s + (input.length > len ? content_tag(:span, extension, :class => 'extension') : ''))
  end

  private 

  def attrs_to_s(attrs)
    return '' if attrs.empty?
    attrs.to_a.map { |attr| %{#{attr[0]}="#{attr[1]}"} }.join(' ')
  end
end
