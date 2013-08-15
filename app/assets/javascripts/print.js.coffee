jQuery ->
  $printLink = $("<a id='print_btn' href='#'>Afdrukken</a>")
  $backLink = $("<a id='back_btn' href='#'>Terug</a>")

  $printLink.click (event) ->
    event.preventDefault()
    window.print()

  $backLink.click (event) ->
    event.preventDefault()    
    history.go(-1)

  $('#content').prepend($printLink).prepend($backLink)

