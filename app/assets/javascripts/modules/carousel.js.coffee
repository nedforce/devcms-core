$ ->
  $.widget "devcms.carousel",
    itemWidth: 0
    itemHeight: 0
    itemCount: 0
    paused: false
    currentPosition: 0
    slideTimer: undefined
    direction: 'horizontal'

    options:
      slideDelay: 10000
      effect: 'slide-horizontal'
      easing: 'swing'
      animationSpeed: 600
      animate: true
    
    _create: ->
      @_setOption 'effect'
      @_setOption 'easing'
      @_setOption 'delay', 'slideDelay'
      @_setOption 'speed', 'animationSpeed'
      @_setBooleanOption 'keyboard-input', 'keyboardInput'

      @_setNavigation()

      # Set with javascript, not css for gracefull degradation
      if @options.effect == 'fade'
        @element.addClass('with-fader')
        $('.slider-image', @element).css('position', 'absolute')
        $('.slider-image', @element).css('opacity', 0)
        $('.slider-image', @element).first().addClass('active').css('opacity', 1)
      else
        $('.slider-image', @element).css('float', 'left')
        $('.slider-items', @element).css('position', 'absolute')
      
      $('.slider-item-title', @element).css('position', 'absolute')
      $('.slider-items-wrapper', @element).css('overflow', 'hidden')

      $('.slider-navigation', @element).show()
      $('.slider-lateral-navigation', @element).show()

      if @paused
        $('.slider-navigation .pause-control', @element).hide()
        $('.slider-navigation .play-control', @element).show()
      else
        @_setTimeout(@_moveToNext)
        $('.slider-navigation .pause-control', @element).show()
        $('.slider-navigation .play-control', @element).hide()

      $('.slider-items').imagesLoaded().always =>
        @_checkDimensions()

    _checkDimensions: ->
      @itemWidth = $('.slider-items-wrapper', @element).width()
      @itemCount = $('.slider-image', @element).length

      $('.slider-image', @element).width(@itemWidth)

      if $('.slider-image img', @element).exists()
        @itemHeight =  Math.max.apply(Math, $('.slider-image img', @element).map( () -> $(@).height() ))
      else
        @itemHeight = $('.slider-image').first().height()

      # Explicitly set widths and height, to prevent cumulative rounding errors
      $('.slider-image', @element).width(@itemWidth)
      $('.slider-image', @element).height(@itemHeight)
      $('.slider-items', @element).width(@itemWidth * @itemCount)

        
      $('.slider-items-wrapper', @element).height(@itemHeight + 30)

      animate = @options.animate
      @options.animate = false
      @_moveToCurrent()
      @options.animate = animate

    _checkCurrentPosition: () ->
      if @currentPosition >= @itemCount
        @currentPosition = 0
      else if @currentPosition < 0
        @currentPosition = @itemCount - 1

    pause: () ->
      @paused = true
      clearTimeout(@slideTimer)
      $('.slider-navigation .pause-control', @element).hide()
      $('.slider-navigation .play-control', @element).show()


    play: () ->
      @paused = false
      @_setTimeout(@_moveToNext)
      $('.slider-navigation .pause-control', @element).show()
      $('.slider-navigation .play-control', @element).hide()

    toggle: ->
     if @paused
        @play()
      else
        @pause()

    # Slidey bits
    _moveToNext: () ->
      @currentPosition += 1
      @_move()

    _moveToPrevious: () ->
      @currentPosition -= 1
      @_move()

    _moveToPosition: (position) ->
      @currentPosition = position      
      @_move()

    _moveToCurrent: (position) ->
      @_moveToPosition @currentPosition

    _move: () ->
      @_checkCurrentPosition()
      $('[data-toggle="slider"]', @element).removeClass('active')
      $('[data-toggle="slider"]', @element).eq(@currentPosition).addClass('active')
      
      if @options.effect == 'fade'
        @_fade()
      else
        @_slideHorizontal()

    _currentItem: () ->
      $('.slider-image', @element).eq(@currentPosition)

    # Element updating
    _setcurrentPositionData: () ->
      currentItem = @_currentItem()
      $('.slider-partial', @element).html($('.slider-item-partial', currentItem).html())

    # Navigation
    _setNavigation: () ->
      @element.on 'click focus', '[data-toggle="slider"]', (event) =>
        event.preventDefault()
        $anchor = $(event.currentTarget)
        position = $('[data-toggle="slider"]', @element).index($anchor)

        @_moveToPosition position
        @pause()

      @element.on 'click', '.slider-control', (event) =>
        event.preventDefault()
        @toggle()        
        
      @element.on 'click', '.slider-navigation-previous', (event) =>
        event.preventDefault()
        @_moveToPrevious()
        @pause()

      @element.on 'click', '.slider-navigation-next', (event) =>
        event.preventDefault()
        @_moveToNext()
        @pause()

    # Effects

    _slideHorizontal: ->
      newLeft = (@currentPosition * @itemWidth * -1)

      if @.options.animate
        $('.slider-items', @element).animate({
            left: newLeft
          }, {
            duration: this.options.animationSpeed,
            queue: false,
            easing: @options.easing,
            complete: () =>
              @_setcurrentPositionData()
              unless @paused
                @_setTimeout(@_moveToNext)
          }
        )
      else
        $('.slider-items', @element).css('left', newLeft)
        unless @paused
          @_setTimeout(@_moveToNext)

    _fade: ->
      if @.options.animate
        $('.slider-image.active').removeClass('active').addClass('previous')
        @_currentItem().addClass('active')

        $('.slider-image.previous', @element).animate({ opacity: 0 }, { duration: this.options.animationSpeed, queue: false })
        $('.slider-image.active', @element).animate({
            opacity: 1
          }, {
            duration: this.options.animationSpeed,
            queue: false,
            complete: () =>
              @_setcurrentPositionData()
              unless @paused
                @_setTimeout(@_moveToNext)
          }
        )

      else
        $('.slider-image.active', @element).css('opacity', 0).removeClass('active')
        @_currentItem().css('opacity', 1).addClass('active')       

        unless @paused
          @_setTimeout(@_moveToNext)

    # Utilities    
    _setOption: (name, optionName = '') ->
      optionName = name if optionName == ''
      @options[optionName] = @element.data(name) if @element.data(name) != '' && @element.data(name)?

    _setBooleanOption: (name, optionName = '') ->
      optionName = name if optionName == ''
      @options[optionName] = true if @element.data(name)?


    destroy: () ->
      $.Widget.prototype.destroy.call( this )

    _setTimeout: (Method, delay) ->
      if(typeof delay == 'undefined') then delay = @options.slideDelay
      clearTimeout(@slideTimer)
      @slideTimer = setTimeout(@Bind(Method), delay)

    Bind: (Method) ->
        # Use for timer functions, since setTimeout() is a method of window object.
        _this = this;
        () ->
          Method.apply( _this, arguments )

  $('[data-toggle=carousel]').carousel()

