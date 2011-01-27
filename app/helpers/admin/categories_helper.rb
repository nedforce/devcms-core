module Admin::CategoriesHelper

  def insert_new_category_combination_link(first_root_category)
    link_to_function t('categories.add_new_combination'), :id => 'insert_new_category_combination_link' do |page|
      page.insert_html :bottom, 'category_selection_fields_wrapper', :partial => '/admin/shared/category_selection_fields', :locals => { :categories => nil, :root_category => nil, :category => nil }
      page.call :observeRootCategorySelectionFields
      page.call :observeCategorySelectionFields
      page.call :activateRemoveCategoryCombinationLinks
      page.call :activateAddCategoryCombinationToFavoritesLinks
    end
  end

  def insert_category_combination_link(category)
    link_to_function image_tag('icons/add.png', :alt => t('categories.insert_combination')), :title => t('categories.insert_combination') do |page|
      if category.is_root_category?
        page.insert_html :bottom, 'category_selection_fields_wrapper', :partial => '/admin/shared/category_selection_fields', :locals => { :categories => category.children, :root_category => category, :category => category }
      else
        parent = category.parent
        page.insert_html :bottom, 'category_selection_fields_wrapper', :partial => '/admin/shared/category_selection_fields', :locals => { :categories => parent.children,   :root_category => parent,   :category => category }
      end

      page.call :observeRootCategorySelectionFields
      page.call :observeCategorySelectionFields
      page.call :activateRemoveCategoryCombinationLinks
      page.call :activateAddCategoryCombinationToFavoritesLinks
    end
  end
end
