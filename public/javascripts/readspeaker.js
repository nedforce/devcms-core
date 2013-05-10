/*global document,$$*/
function showReadspeaker(anchor) {
  var flash_url, flash, readspeaker_button, page_container, buttons_container;

  flash_url = 'http://media.readspeaker.com/flash/readspeaker20.swf?mp3=' + escape(anchor.href) + '&autoplay=1&rskin=bump';

  flash = '<object class="readspeaker_player" type="application/x-shockwave-flash" data="' + flash_url + '">\
    <param name="movie" value="' + flash_url + '" />\
    <param name="quality" value="high" />\
    <param name="SCALE" value="exactfit" />\
    <param name="wmode" value="transparent" />\
    <embed wmode="transparent" src="' + flash_url + '" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwaveflash" scale="exactfit"></embed>\
  </object>';

  readspeaker_button = anchor.up('.readspeaker_button');
  readspeaker_button.hide();

  if (anchor.hasClassName('topRightReadspeaker')) {
    page_container = readspeaker_button.up('.regularPage');
    page_container.insert({ top: flash });
  } else {
    buttons_container = readspeaker_button.up('.buttons');
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

document.observe('dom:loaded', function () {
  javascriptifyReadspeakerLinks();
});
