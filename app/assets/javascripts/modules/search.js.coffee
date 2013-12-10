jQuery ->  
  if $('.searchPage').length > 0
    
    $('#static_programme_and_project_selector').hide() if $('#static_programme_and_project_selector').length > 0
    $('#dynamic_programme_and_project_selectors').removeClass('hidden') if $('#dynamic_programme_and_project_selectors').length > 0
    
    $('.show-advanced-search-options').click (event) ->
      event.preventDefault()
      $('#advanced_search').removeClass 'hidden'
      $('#top_search_button').addClass 'hidden'
      $('#show_advanced_options').addClass 'hidden'
      
    $('.hide-advanced-search-options').click (event) ->
      event.preventDefault()
      $('#advanced_search').addClass 'hidden'
      $('#top_search_button').removeClass 'hidden'
      $('#show_advanced_options').removeClass 'hidden'
