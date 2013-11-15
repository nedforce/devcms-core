class SlideShow
  
  constructor: (@container, options) ->
    @options = $.extend {
      fadeDuration: 3000 # Default fade duration if none is specified. In milliseconds.
      displayDuration: 5000 # Default display duration if none is specified. In milliseconds.
      fadeOutStartToFadeInStartDelay: 0 # Default delay next slide starts fading in after current slide has begun fading out. In milliseconds.
      }, options || {}
    
    @slides = @container.data('slides')
    @currentSlide = @container.children().first()
    @currentSlideIndex = 0

  # Call this function to start the image cycler.
  start: () -> @startTimer()

  # Do not call this function directly.
  startTimer: () => setTimeout (=> @loadNextSlide()), @options.displayDuration

  # Do not call this function directly.
  loadNextSlide: () ->
    $("##{@previousSlide.attr('id')}", @container).remove() if @previousSlide
    @previousSlide = @currentSlide
    @currentSlideIndex++
    @currentSlideIndex = 0 if @currentSlideIndex == @slides.length
    @buildCurrentSlide @slides[@currentSlideIndex]

  fadePreviousSlideOut: () =>
    @previousSlide.fadeOut @options.fadeDuration
    setTimeout (=> @fadeCurrentSlideIn()), @options.fadeOutStartToFadeInStartDelay

  fadeCurrentSlideIn: () ->
    @currentSlide.fadeIn @options.fadeDuration, @startTimer

  # Do not call this function directly.
  buildCurrentSlide: (slide) ->
    @currentSlide = $("<img src='#{slide['url']}' id='#{slide['id']}' alt='#{slide['alt']}' title='#{slide['title']}' style='display: none' />")

    @container.append(@currentSlide)
    @fadePreviousSlideOut()
      
# Slideshow
jQuery ->
  
  headerSlideShow = new SlideShow $('#header-slideshow'), {
    fadeDuration: 3000,
    displayDuration: 6000,
    fadeOutStartToFadeInStartDelay: 0
  }
  
  headerSlideShow.start() if headerSlideShow.slides? && headerSlideShow.slides.length > 1
