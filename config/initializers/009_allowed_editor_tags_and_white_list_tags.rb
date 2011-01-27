# Allowed tags for TinyMCE HTML editors.
# Note that we replace +b+ and +i+ tags with +strong+ and +em+ tags, respectively.
# TODO: Make this configurable here, instead of hardcoding it in +HtmlEditorHelper+
# HtmlEditorHelper.tags = "strong,strong/b,em,em/i,p,code,pre,tt,sub,sup,br,ul,ol,li,abbr,acronym,a[href|title|target],blockquote"

# Allowed tags for views.
# Keep this synced with the allowed tags for TinyMCE HTML editors.
WhiteListHelper.tags = %w(img strong em p code pre tt sub sup br ul ol li abbr acronym a blockquote span h2 h3 abbr)

# Allowed attributes for views.
# Keep this synced with the allowed attributes for TinyMCE HTML editors.
WhiteListHelper.attributes = %w(href title target lang xml:lang src alt width height)

# Alias the +white_list+ method to +w+.
module WhiteListHelper
  alias_method :w, :white_list
end
