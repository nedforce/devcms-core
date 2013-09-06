
function setupTagComboBoxes(prefix, tagStore) {
  wrapper = new Element('div', {class: 'fieldSet'})
  $(prefix + '_tag_list_wrapper').appendChild(wrapper)
  values  = castStringToArray($F(prefix + '_tag_list'))
  Element.remove(prefix + '_tag_list')
  for( i = 0; i < 3; i++) {
    new Ext.form.ComboBox({
      renderTo: wrapper,
      id:       prefix + "_tag_" + i,
      name:     prefix + "[tag_list][]",
      value:    String.interpret(values[i]).strip(),
      store:    tagStore
    })
  }
}

function castStringToArray(str){
  return String.interpret(str).split(",");
}