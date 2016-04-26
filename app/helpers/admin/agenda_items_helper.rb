module Admin::AgendaItemsHelper
  # The functionality of this method is exactly the same as
  # +options_from_collection_for_select+, except that a blank option is
  # included.
  def options_from_collection_for_select_with_blank_option(collection, value_method, text_method, selected = nil)
    content_tag(:option, '', value: '') + options_from_collection_for_select(collection, value_method, text_method, selected)
  end
end
