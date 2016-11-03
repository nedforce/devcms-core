module GoogleSiteSearchesHelper
  def search_tab(text, tab)
    html_class = 'active' if params[:tab] == tab
    content_tag(:li) do
      link_to(text.capitalize, params.merge(tab: tab, page: 1), class: html_class)
    end
  end
end
