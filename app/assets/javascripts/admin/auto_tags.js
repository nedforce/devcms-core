function castStringToArray(str){
  return str.split(",");
}

function removeWhiteSpaces(str){
  return str.replace(/^\s*/, "");
}

function autoComplete (all_tags, controller){
  var form = getTagListForm (controller);
  //current_input_word becomes the word the cursor is currently at
  var current_input_word = removeWhiteSpaces( castStringToArray( form.value )[ getCursorWordIndex(form) ] );
  var suggested_output = getSuggestions(all_tags, current_input_word);
  setSuggestionsAsOutput(suggested_output, form, controller, current_input_word);
}

function getSuggestions(all_tags, current_input_word){
  var suggested_input = [];
  if (current_input_word.length > 0 ){
    for (var i = 0; i < all_tags.length && suggested_input.length < 5; i++){
      var index = all_tags[i].search("^" + current_input_word + ".");
      if (index !== -1){
        suggested_input.push(all_tags[i]);
      }
    }
    for (var i = 0; i < all_tags.length && suggested_input.length < 5; i++){
      var index = all_tags[i].search("." + current_input_word);
      if (index !== -1){
        suggested_input.push(all_tags[i]);
      }
    }
  }
  return suggested_input;
}

function setSuggestionsAsOutput (output_list, form, controller, current_input_word){
  var output_field = $("auto_complete_dropdown");
  output_field.innerHTML = toHTMLList(output_list, current_input_word, controller);
  output_field.style.display = "block";
}

function getTagListForm (controller){
  return $(controller + "_tag_list");
}

function fattenPartStringInHTML(entire_string, part_string){
  return entire_string.replace(part_string, "<b>" + part_string + "</b>");
}

function toHTMLList(string_array, part_string, controller){
  var html_list = "<ul>";
  for (var i = 0; i < string_array.length; i++){
    html_list += "<li onmousedown=\"fillInAutoComplete('"+ controller + "', '" + string_array[i] + "')\">" + fattenPartStringInHTML(string_array[i], part_string) + " </li>";
  }
  html_list += "</ul>";
  return html_list;
}

function hideAutoComplete(){
  $("auto_complete_dropdown").hide();
}

function fillInAutoComplete (controller, single_value){
  var form = getTagListForm (controller);
  var current_cursor_pos_word = getCursorWordIndex(form);
  var string_array = castStringToArray(form.value);
  string_array[current_cursor_pos_word] = single_value;

  var new_form_value = "";
  for (var i = 0; i < string_array.length - 1; i++){
    new_form_value += removeWhiteSpaces( string_array[i] ) + ", ";
  }
  //add the last one without ", " at the end
  new_form_value += removeWhiteSpaces( string_array[ string_array.length - 1] );
  
  form.value = new_form_value;
  $("auto_complete_dropdown").innerHTML = "";
  form.focus();
}

function getCursorWordIndex(form) {
  var current_input_word_raw_array = castStringToArray(form.value);
  var current_cursor_pos = getCursorPos(form);

  for (var i = 0; i < current_input_word_raw_array.length; i++){
    current_cursor_pos -= current_input_word_raw_array[i].length + 1;
    if (current_cursor_pos < 0){
      return  i;
    }
  }
  return current_input_word_raw_array.length - 1;
}

function getCursorPos(form) {
    var start = 0, end = 0, normalizedValue, range,
        textInputRange, len, endRange;

    if (typeof form.selectionStart == "number") {
        start = form.selectionStart;
    } else {
      //for non-normal browsers (<= IE8)
      //copied from http://stackoverflow.com/questions/3053542/how-to-get-the-start-and-end-points-of-selection-in-text-area
        range = document.selection.createRange();

        if (range && range.parentElement() == form) {
            len = form.value.length;
            normalizedValue = form.value.replace(/\r\n/g, "\n");

            textInputRange = form.createTextRange();
            textInputRange.moveToBookmark(range.getBookmark());

            endRange = form.createTextRange();
            endRange.collapse(false);

            if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                start = end = len;
            } else {
                start = -textInputRange.moveStart("character", -len);
                start += normalizedValue.slice(0, start).split("\n").length - 1;
            }
        }
    }

    return start;
}

function addEventListenersOnTags(){
  if ($('data_capsule_for_tags')) {
    var controller = $('data_capsule_for_tags').attributes.getNamedItem("controller").value;
    var tags = JSON.parse( $('data_capsule_for_tags').attributes.getNamedItem("tags").value );
    getTagListForm (controller).observe('keyup', function(event) { autoComplete(tags, controller) });
    getTagListForm (controller).observe('focus', function(event) { autoComplete(tags, controller) });
    getTagListForm (controller).observe('blur', function(event) { hideAutoComplete() });
  }
}

Ajax.Responders.register({
  onComplete: function() {
    addEventListenersOnTags();
  }
});