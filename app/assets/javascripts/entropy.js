var entropy_state = 0;
var privileged_user = false;

function calculateAlphabetSize(password) {
  var alphabet = 0, lower = false, upper = false, numbers = false, symbols1 = false, symbols2 = false, other = '', c, i;

  for (i = 0; i < password.length; i++) {
    c = password[i];
    if (!lower && 'abcdefghijklmnopqrstuvwxyz'.indexOf(c) >= 0) {
      alphabet += 26;
      lower = true;
    } else if (!upper && 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.indexOf(c) >= 0) {
      alphabet += 26;
      upper = true;
    } else if (!numbers && '0123456789'.indexOf(c) >= 0) {
      alphabet += 10;
      numbers = true;
    } else if (!symbols1 && '!@#$%^&*()'.indexOf(c) >= 0) {
      alphabet += 10;
      symbols1 = true;
    } else if (!symbols2 && '~`-_=+[]{}\\|;:\'",.<>?/'.indexOf(c) >= 0) {
      alphabet += 22;
      symbols2 = true;
    } else if (other.indexOf(c) === -1) {
      alphabet += 1;
      other += c;
    }
  }

  return alphabet;
}

function calculateEntropy(password) {
  if (password.length === 0) {
    return 0;
  }
  var entropy = password.length * Math.log(calculateAlphabetSize(password)) / Math.log(2);
  return (Math.round(entropy * 100) / 100);
}

Event.observe(window, 'load', function () {
  privileged_user = $('password_rater') != undefined;
  $("password_rater").hide();
  $('password_rater').setStyle({ margin: '2px 0px', padding: '5px', width: '304px' });

  if (privileged_user) {
    $('user_password').observe('keyup', function (event) {
      element = Event.element(event);
      if (element.value != '') {
        $("password_rater").show();
        var entropy = calculateEntropy(element.value);
        if (entropy > (good_entropy != undefined ? good_entropy : 156)) {
          if (entropy_state != 1) {
            $("password_rater").update(I18n.t('good', 'password_entropy'));
            $("password_rater").setStyle({ border: '#458B00 solid 1px' });
            entropy_state = 1;
          }
        } else if (entropy > (required_entropy != undefined ? required_entropy : 66)) {
          if (entropy_state != 2) {
            $("password_rater").update(I18n.t('required', 'password_entropy'));
            $("password_rater").setStyle({ border: '#458B00 dotted 1px' });
            entropy_state = 2;
          }
        } else if (entropy_state != 3) {
          $("password_rater").update(I18n.t('bad', 'password_entropy'));
          $("password_rater").setStyle({ border: '#FF0000 solid 1px' });
          entropy_state = 3;
        }
      } else if (entropy_state != 0) {
        entropy_state = 0;
        $("password_rater").hide();
      }
    });
  }
});
