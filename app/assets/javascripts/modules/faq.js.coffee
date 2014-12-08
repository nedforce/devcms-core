$ ->
  $(".faq_theme_listing .answer").hide()
  $(".faq_theme_listing .question>a").on 'click', (event) ->
    event.preventDefault()
    if $(this).toggleClass('expanded').parent().next().toggle().is(":visible")
      jQuery.ajax($(this).attr('href'))
