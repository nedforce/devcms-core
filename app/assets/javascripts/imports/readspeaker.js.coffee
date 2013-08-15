$.fn.loadReadspeaker = () ->
  return this.each ->
    $link = $(this)
    
    flashUrl = "http://media.readspeaker.com/flash/readspeaker20.swf?mp3=#{ escape($link.attr('href')) }&autoplay=1&rskin=bump"
    flash = "<object class='readspeaker_player' type='application/x-shockwave-flash' data='#{flashUrl}'>
      <param name='movie' value='#{flashUrl}' />
      <param name='quality' value='high' />
      <param name='SCALE' value='exactfit' />
      <param name='wmode' value='transparent' />
      <embed wmode='transparent' src='#{flashUrl}' quality='high' pluginspage='http://www.macromedia.com/go/getflashplayer' type='application/x-shockwaveflash' scale='exactfit'></embed>
      </object>"

    readspeakerButton = $link.closest('.readspeaker_button')
    readspeakerButton.hide()

    if $link.hasClass('topRightReadspeaker')
      pageContainer = readspeakerButton.closest('.regularPage')
      pageContainer.prepend flash
    else
      buttonsContainer = readspeakerButton.closest('.buttons')
      buttonsContainer.append flash

jQuery ->
  $('a.readspeaker_link').click (event) -> 
    event.preventDefault()
    $(this).loadReadspeaker()
