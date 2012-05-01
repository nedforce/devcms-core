class Sanitize
  module Config
    CUSTOM = {
      :elements => %w(img strong em p code pre tt sub sup br ul ol li abbr acronym a blockquote span h2 h3 abbr),

      :attributes => {
        :all => %w(href title target lang xml:lang src alt width height)
      }
    }
  end
end