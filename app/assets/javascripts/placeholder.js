// provide input hints
document.observe('dom:loaded', function () {
  var PLACEHOLDER_SUFFIX = '_placeholder'; // used for password inputs

  $$('input[placeholder]').each(function (input) {
    var label, placeholder,
      placeholder_text = input.readAttribute('placeholder');

    if (input.readAttribute('type') == 'password') {
      placeholder = input.clone();
      placeholder.type = 'text'; // not "password"
      placeholder.value = placeholder_text;
      placeholder.addClassName('placeholder');

      if (input.id) {
        // update input id and label
        placeholder.id += PLACEHOLDER_SUFFIX;
        label = $$('label[for="' + input.id + '"]');
        label.invoke('writeAttribute', 'for', input.id + PLACEHOLDER_SUFFIX);
      }

      input.writeAttribute({ 'accesskey': '', 'tabindex': '' });
      input.hide().insert({ 'before': placeholder });

      // when placeholder input gains focus,
      // hide it and show "real" password input
      Event.observe(placeholder, 'focus', function () {
        this.hide();
        input.show();
        Form.Element.focus(input);
      });

      // when "real" password input loses focus,
      // if it's empty, hide it and show placeholder input
      Event.observe(input, 'blur', function () {
        if (this.value === '') {
          this.hide();
          placeholder.show();
        }
      });
    } else {
      // insert placeholder text
      input.addClassName('placeholder').value = placeholder_text;

      Event.observe(input, 'focus', function () {
        if (this.hasClassName('placeholder')) {
          this.clear().removeClassName('placeholder');
        }
      });
      Event.observe(input, 'blur', function () {
        if (this.value === '') {
          this.addClassName('placeholder').value = placeholder_text;
        }
      });
    }
  });
});
