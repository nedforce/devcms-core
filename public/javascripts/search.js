document.observe('dom:loaded', function() {
  observeProgrammeSelectionField();
});

function observeProgrammeSelectionField() {
  var programme_select = $('programme');

  programme_select.observe('change', function(event) {
    getProjectsForProgramme(programme_select.getValue());
    event.stop();
  });
}

function getProjectsForProgramme(root_category_id) {
  var project_selection_field = $('project_selection_field');

  new Ajax.Updater(project_selection_field, '/search/projects', {
    method: 'get',
    parameters: { programme_id: root_category_id }
  });
}