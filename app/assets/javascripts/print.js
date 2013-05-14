/*global document,window,$*/
function insertPrintButtons() {
  var printLink, backLink;

  printLink = new Element('a', {
    'id': 'print_btn',
    'href': '#'
  }).update('Afdrukken');

  backLink = new Element('a', {
    'id': 'back_btn',
    'href': '#'
  }).update('Terug');

  printLink.observe('click', function (event) {
    window.print();
    event.stop();
  });

  backLink.observe('click', function (event) {
    history.go(-1);
    event.stop();
  });

  $('content').insert({ top: printLink });
  $('content').insert({ top: backLink });
}

document.observe('dom:loaded', function () {
  insertPrintButtons();
});
