$ ->
  cache = {}

  sortResults = (term, results) ->
    matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( term ), "i" )
    sortedResults = $.grep results, (item) ->
      matcher.test( item )
    sortedResults

  $('#search_terms').autocomplete
    autoFocus: false,
    source: (request, response) ->
      term = request.term
      # Only do JSON request for the first two characters
      cache_key = term.substring(0,2)
      if cache[cache_key] != undefined
        response( sortResults(term, cache[ cache_key ]) )
      else
        $.getJSON "/search_suggestions", request, ( results, status, xhr) =>
          cache[ cache_key ] =  results
          response( sortResults(term, results) )
    select: (event, ui) ->
      $(this).val( ui.item.value )
      $(this).closest('form').submit()
