// Default values

var defaultFadeDuration = 3.0; // Default fade duration if none is specified. In seconds.
var defaultDisplayDuration = 5000; // Default display duration if none is specified. In milliseconds.
var defaultFadeOutStartToFadeInStartDelay = 0.0; // Default delay next slide starts fading in after current slide has begun fading out. In milliseconds.
var defaultContainerClassName = 'header-slideshow'; // Default container class name.

// Classes

var SlideShow = Class.create({
  
  // Call this function to start the image cycler.
  start: function() {
    this.startTimer();
  },
  
  // Do not call this function directly.
  startTimer: function () {
    var _self = this; // Hack required because Javascript timers execute in a global context
		setTimeout(function() { _self.loadNextSlide() }, this.options.displayDuration);
  },
  
  // Do not call this function directly.
  loadNextSlide: function() {
    if (this.previousSlide) {
      this.container.removeChild(this.previousSlide);
    }

    this.previousSlide = this.currentSlide;
    this.currentSlideIndex++;

    if (this.currentSlideIndex == this.slides.length) {
      this.currentSlideIndex = 0;
    }

    this.buildCurrentSlide(this.slides[this.currentSlideIndex]);
  },
  
  fadePreviousSlideOut: function() {
    this.previousSlide.fade({ duration: this.options.fadeDuration / 1000 });
		var _self = this; // Hack required because Javascript timers execute in a global context
		setTimeout(function() { _self.fadeCurrentSlideIn() }, this.options.fadeOutStartToFadeInStartDelay);
  },
  
  fadeCurrentSlideIn: function() {
    this.currentSlide.appear({ duration: this.options.fadeDuration / 1000, afterFinish: this.startTimer.bindAsEventListener(this) });
  },
  
  // Do not call this function directly.
  buildCurrentSlide: function(slide) {
    this.currentSlide = new Element("img", { 'src': slide['url'], 'id': slide['id'], 'title': slide['title'], 'style' : 'display: none'});
    
		this.container.appendChild(this.currentSlide);
    this.fadePreviousSlideOut();
  },
    
  // Do not call this function directly.
  initialize: function(slides, options) {
    if (slides.length == 0) {
      throw 'passed in slides list is empty';
    }

		this.options = Object.extend({
      fadeDuration: defaultFadeDuration,
      displayDuration: defaultDisplayDuration,
			fadeOutStartToFadeInStartDelay: defaultFadeOutStartToFadeInStartDelay,
			containerClassName: defaultContainerClassName
    }, options || {});    
        
    this.container = $(this.options.containerClassName);
    this.slides = slides;
    this.currentSlide = this.container.down();
    this.currentSlideIndex = 0;
	}
});

