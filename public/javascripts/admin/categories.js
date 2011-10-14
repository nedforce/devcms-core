function javascriptifyCategoryFields() {
  observeRootCategorySelectionFields();
  observeCategorySelectionFields();
  activateRemoveCategoryCombinationLinks();
  activateAddCategoryCombinationToFavoritesLinks();
  activateRemoveCategoryCombinationFromFavoritesLinks();
}

function getSynonymsForCategory(category_id, field) {
  new Ajax.Updater(field.down('.category_synonyms_field_wrapper'), '/admin/categories/' + category_id + '/synonyms', {
    method: 'get'
  });
}

function getCategoriesForRootCategory(root_category_id, field) {
  var category_selection_element = field.down('.category_selection_field select');

  new Ajax.Updater(category_selection_element, '/admin/categories/' + root_category_id + '/category_options', {
    method: 'get',
    onComplete: function () {
      getSynonymsForCategory(category_selection_element.getValue(), field);
    }
  });
}

function observeRootCategorySelectionFields() {
  $$('.category_selection_fields').each(function (field) {
    var select = field.down('.root_category_selection_field select');

    select.stopObserving('change');

    select.observe('change', function (event) {
      getCategoriesForRootCategory(select.getValue(), field);
      event.stop();
    });
  });
}

function observeCategorySelectionFields() {
  $$('.category_selection_fields').each(function (field) {
    var select = field.down('.category_selection_field select');

    select.stopObserving('change');

    select.observe('change', function (event) {
      getSynonymsForCategory(select.getValue(), field);
      event.stop();
    });
  });
}

function activateRemoveCategoryCombinationLinks() {
  var remove_category_combination_links = $$('.remove_category_combination_link');

  // if (remove_category_combination_links.size() == 0) {
  //   var link = remove_category_combination_links[0];
  //   link.stopObserving('click');
  //   link.hide();
  // } else {
    remove_category_combination_links.each(function (link) {
      link.stopObserving('click');

      link.observe('click', function (event) {
        link.up('.category_selection_fields').remove();
        event.stop();
        activateRemoveCategoryCombinationLinks();
      });

      if (!link.visible()) {
        link.show();
      }
    });
  // }
}

function activateRemoveCategoryCombinationFromFavoritesLinks() {
  $$('.remove_category_combination_from_favorites_link').each(function (link) {
    link.stopObserving('click');

    link.observe('click', function (event) {
      removeCategoryCombinationFromFavorites(link.up('td').down('input').getValue());
      event.stop();
    });
  });
}

function removeCategoryCombinationFromFavorites(category_id) {
  new Ajax.Updater('favorite_category_combinations', '/admin/categories/' + category_id + '/remove_from_favorites', {
    method: 'put',
    onComplete: activateRemoveCategoryCombinationFromFavoritesLinks
  });
}

function addCategoryCombinationToFavorites(category_id) {
  new Ajax.Updater('favorite_category_combinations', '/admin/categories/' + category_id + '/add_to_favorites', {
    method: 'put',
    onComplete: activateRemoveCategoryCombinationFromFavoritesLinks
  });
}

function activateAddCategoryCombinationToFavoritesLinks() {
  $$('.add_category_combination_to_favorites_link').each(function (link) {
    link.stopObserving('click');

    link.observe('click', function (event) {
      addCategoryCombinationToFavorites(link.up('.category_selection_fields').down('.category_selection_field select').getValue());
      event.stop();
    });
  });
}
