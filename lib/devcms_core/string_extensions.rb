class String
  def to_valid_utf8
    if encoding.name == 'UTF-8'
      chars.select(&:valid_encoding?).join
    else
      encode('UTF-8', undef: :replace, invalid: :replace, replace: '')
    end
  end
end
