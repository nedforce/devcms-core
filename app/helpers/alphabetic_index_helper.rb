module AlphabeticIndexHelper
  def index_title(page, letter)
    if page.title.upcase.starts_with?(letter.upcase)
      page.title
    else
      title = page.title_alternative_list.find { |t| t.upcase.starts_with?(letter.upcase) }
      "#{title.capitalize} (#{page.title.capitalize}) "
    end
  end
end
