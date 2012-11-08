document.observe('dom:loaded', function () {
  $$('.carousel-wrapper .carousel-control').each(function (elem) {
    $(elem).setOpacity(0.5);
  });
});
