entropy_state = 0
privileged_user = false

calculateAlphabetSize = (password) ->
  alphabet = 0
  lower = false
  upper = false
  numbers = false
  symbols1 = false
  symbols2 = false
  other = ''
  
  for i in [0..password.length-1] by 1    
    c = password[i]
    if !lower && 'abcdefghijklmnopqrstuvwxyz'.indexOf(c) >= 0
      alphabet += 26
      lower = true
    else if !upper && 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.indexOf(c) >= 0
      alphabet += 26
      upper = true
    else if !numbers && '0123456789'.indexOf(c) >= 0
      alphabet += 10
      numbers = true
    else if !symbols1 && '!@#$%^&*()'.indexOf(c) >= 0
      alphabet += 10
      symbols1 = true
    else if !symbols2 && '~`-_=+[]{}\\|;:\'",.<>?/'.indexOf(c) >= 0
      alphabet += 22
      symbols2 = true
    else if other.indexOf(c) == -1
      alphabet += 1
      other += c

  return alphabet

calculateEntropy = (password) ->
  return 0 if password.length == 0
  entropy = password.length * Math.log(calculateAlphabetSize(password)) / Math.log(2)
  Math.round(entropy * 100) / 100

jQuery ->
  $rater = $('#password_rater')  
  privileged_user = $rater.length > 0

  if privileged_user
    $rater.hide().css({ margin: '2px 0px 4px 120px', padding: '5px', width: '297px' })
    good_entropy = $rater.data('good-entropy')
    required_entropy = $rater.data('required-entropy')    

    $('#user_password').keyup ->
      $element = $(this)
      
      if $element.value != ''
        $rater.show()
        
        entropy = calculateEntropy($element.val())
        if entropy > (if good_entropy then good_entropy else 156)
          if entropy_state != 1
            $rater.html(I18n.t('good', 'password_entropy')).css({ border: '#458B00 solid 1px' })
            entropy_state = 1
        else if entropy > (if required_entropy then required_entropy else 66)
          if entropy_state != 2
            $rater.html(I18n.t('required', 'password_entropy')).css({ border: '#458B00 dotted 1px' })
            entropy_state = 2
        else if entropy_state != 3
          $rater.html(I18n.t('bad', 'password_entropy')).css({ border: '#FF0000 solid 1px' })
          entropy_state = 3
      else if entropy_state != 0
        entropy_state = 0
        $rater.hide()