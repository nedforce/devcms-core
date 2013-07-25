function autoComplete (form, all_tags, controller){
  var current_cursor_pos_word = getCursorIndexWord(form);
  var current_input_word_raw_array = form.value.split(",");

  var current_input_word = current_input_word_raw_array[current_cursor_pos_word].replace(/^\s*/, "");
  var length = all_tags.length;
  var suggested_input = new Array();
  if (current_input_word.length > 0 ){
    for (var i = 0; i < length && suggested_input.length < 5; i++){
      var index = all_tags[i].search("^" + current_input_word + "..*?");
      if (index != -1){
        suggested_input.push(all_tags[i]);
      }
    }
    for (var i = 0; i < length && suggested_input.length < 5; i++){
      var index = all_tags[i].search("..*?" + current_input_word);
      if (index != -1){
        suggested_input.push(all_tags[i]);
      }
    }
  }
  
  var field_text = "<ul>";
  for (var i = 0; i < suggested_input.length; i++){
    field_text += "<li onclick=\"fillInAutoComplete('"+ controller + "', '" + suggested_input[i] + "')\">" + suggested_input[i].replace(current_input_word, "<b>" + current_input_word + "</b>") + " </li>";
  }
  field_text += "</ul>";
  var output_field = document.getElementById("auto_complete_dropdown");
  output_field.innerHTML = field_text;
  output_field.style.display = "block";
  return;
}

function hideAutoComplete(){
  document.getElementById("auto_complete_dropdown").style.display = "none";
  return;
}

function fillInAutoComplete (controller, single_value){
  var form = document.getElementById(controller+"_tag_list");
  var current_cursor_pos_word = getCursorIndexWord(form);
  var multiple_value = form.value.split(",");
  multiple_value[current_cursor_pos_word] = single_value;
  var output_value = "";
  for (var i = 0; i < multiple_value.length-1; i++){
    output_value += multiple_value[i].replace(/^\s*/, "") + ", ";
  }
  output_value += multiple_value[multiple_value.length - 1].replace(/^\s*/, "");
  form.value = output_value;
  document.getElementById("auto_complete_dropdown").innerHTML = "";
  form.focus();
  return;
}

function getCursorIndexWord(form) {
  var current_input_word_raw_array = form.value.split(",");
  var current_cursor_pos = getInputSelection(form);
  var current_cursor_pos_word = current_input_word_raw_array.length - 1;

  for (var i = 0; i < current_input_word_raw_array.length; i++){
    current_cursor_pos -= current_input_word_raw_array[i].length + 1;
    if (current_cursor_pos < 0){
      current_cursor_pos_word = i;
      break;
    }
  }
  return current_cursor_pos_word;
}

//also get the current cursor pos in IE <8
function getInputSelection(el) {
    var start = 0, end = 0, normalizedValue, range,
        textInputRange, len, endRange;

    if (typeof el.selectionStart == "number") {
        start = el.selectionStart;
    } else {
        range = document.selection.createRange();

        if (range && range.parentElement() == el) {
            len = el.value.length;
            normalizedValue = el.value.replace(/\r\n/g, "\n");

            textInputRange = el.createTextRange();
            textInputRange.moveToBookmark(range.getBookmark());

            endRange = el.createTextRange();
            endRange.collapse(false);

            if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                start = end = len;
            } else {
                start = -textInputRange.moveStart("character", -len);
                start += normalizedValue.slice(0, start).split("\n").length - 1;

                if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
                    end = len;
                } else {
                    end = -textInputRange.moveEnd("character", -len);
                    end += normalizedValue.slice(0, end).split("\n").length - 1;
                }
            }
        }
    }
    return start;
}