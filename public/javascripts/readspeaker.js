document.observe('dom:loaded', function () {
  javascriptifyReadspeakerLinks();
});

function showReadspeaker(anchor) {
  var flash_url = 'http://media.readspeaker.com/flash/readspeaker20.swf?mp3=' + escape(anchor.href) + '&autoplay=1&rskin=bump';

  var flash = '<object class="readspeaker_player" type="application/x-shockwave-flash" data="' + flash_url + '">\
    <param name="movie" value="' + flash_url + '" />\
    <param name="quality" value="high" />\
    <param name="SCALE" value="exactfit" />\
    <param name="wmode" value="transparent" />\
    <embed wmode="transparent" src="' + flash_url + '" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwaveflash" scale="exactfit"></embed>\
  </object>';

  var readspeaker_button = anchor.up('.readspeaker_button');
  readspeaker_button.hide();

  if (anchor.hasClassName('topRightReadspeaker')) {
    var page_container = readspeaker_button.up('.regularPage');
    page_container.insert({ top: flash });
  } else {
    var buttons_container = readspeaker_button.up('.buttons');
    buttons_container.insert({ bottom: flash });
  }
}

function javascriptifyReadspeakerLinks() {
  $$('a.readspeaker_link').each(function (anchor) {
    anchor.observe('click', function (event) {
      showReadspeaker(anchor);
      event.stop();
    });
  });
}
