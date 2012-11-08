function setOpacity() {
  $$('.carousel-wrapper .carousel-control').each(function (elem) {
    $(elem).setStyle({
      '-ms-filter': "progid:DXImageTransform.Microsoft.Alpha(Opacity=50)",
      'filter': 'alpha(opacity=50)',
      'opacity': '0.5'
    });
  });
}

document.observe('dom:loaded', function () {
  setOpacity();
});
