# The maximum number of pixels with which the text can be sized up or down:
maxDiff = 6
# The element names of which to resize the text:
elements = 'body, td, th, div, span, li, a, h1, h2, h3, h4, input, textarea, select';

# Sets the text's size in an element.
#
# *Arguments*
# el - The element of which to resize the text.
# newSize - The new size of the text in pixels.
window.setFontSize = ($element, newSize) ->
  diff = newSize - $element.data('originalSize')
  if Math.abs(diff) < maxDiff
    $element.css 'fontSize', newSize + 'px'
    $.cookie('fontSizeDiff', diff, { expires: 365, path: '/' })

# Resizes the text of all elements in the DOM.
#
# *Arguments*
#* i - The number of pixels to increase the text's size with (negative number allowed).
window.resizeFonts = (i) ->
  $(elements)
    .each ->
      $element = $(this)
      currentFontSize = parseInt($element.css('fontSize'))
      $element.data 'prevSize', currentFontSize
      $element.data('originalSize', currentFontSize) if !$element.data('originalSize')
    .each ->
      $element = $(this)
      window.setFontSize($element, parseInt($element.data 'prevSize') + i)

# Increases the text size of all elements with 1px.
window.upsizeFont = () -> window.resizeFonts(1)

# Decreases the text size of all elements with 1px.
window.downsizeFont = () -> window.resizeFonts(-1)

# Resets the text size of all elements to its original size.
window.resetFontSize = () ->
  $(elements).each ->
    $element = $(this)
    window.setFontSize($element, $element.data('originalSize')) if $element.data('originalSize')


# Initializes the text size of all elements to the size last set by the user.
window.initFontSize = () ->
  diff = $.cookie('fontSizeDiff')
  window.resizeFonts(parseInt(diff, 10)) if diff

# Init font size when DOM has been fully loaded:
$ -> window.initFontSize()
