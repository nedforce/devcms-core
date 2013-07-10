function autoComplete (form, all_tags, controller){
  var current_input_word_raw_array = form.value.split(",");
  var current_input_word = current_input_word_raw_array[current_input_word_raw_array.length - 1].replace(/^\s*/, "");
  var length = all_tags.length;
  var suggested_input = new Array();
  if (current_input_word.length > 0 ){
    for (var i = 0; i < length && suggested_input.length < 5; i++){
      if ( all_tags[i].search("^" + current_input_word + ".+") != -1){
        suggested_input.push(all_tags[i]);
      }
    }
    for (var i = 0; i < length && suggested_input.length < 5; i++){
      if ( all_tags[i].search(".+" + current_input_word) != -1){
        suggested_input.push(all_tags[i]);
      }
    }
  }
  
  var field_text = "<ul>";
  for (var i = 0; i < suggested_input.length; i++){
    field_text += "<li onclick=\"fillInAutoComplete('"+ controller + "', '" + suggested_input[i] + "')\">" + suggested_input[i] + " </li>";
  }
  field_text += "</ul>"
  document.getElementById("auto_complete_dropdown").innerHTML = field_text;
  return;
}

function fillInAutoComplete (controller, single_value){
  var form = document.getElementById(controller+"_tag_list");
  var multiple_value = form.value.split(",");
  var output_value = "";
  for (var i = 0; i < multiple_value.length - 1; i++){
    output_value += multiple_value[i].replace(/^\s*/, "") + ", ";
  }
  output_value += single_value;
  form.value = output_value;
  document.getElementById("auto_complete_dropdown").innerHTML = "";
  form.focus();
  return;
}