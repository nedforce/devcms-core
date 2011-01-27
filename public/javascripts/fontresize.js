/* requires CookieJar */

// The maximum number of pixels with which the text can be sized up or down:
var maxDif = 6;
// The element names of which to resize the text:
var els = 'body, td, th, div, span, li, a, h1, h2, h3, h4, input, textarea, select';

// Init CookieJar
var jar = new CookieJar({  
    expires: 3600*24*365, // one year
    path: '/'
}); 

/*
* Sets the text's size in an element.
*
* *Arguments*
* el - The element of which to resize the text.
* newSize - The new size of the text in pixels.
*/
setFontSize = function(el, newSize){  
    var diff = newSize - el.originalSize;
    if(Math.abs(diff) < maxDif){
      el.setStyle({fontSize: newSize + 'px'});
      jar.put('fontSizeDiff', diff);
    }
};

/*
* Resizes the text of all elements in the DOM.
*
* *Arguments*
* i - The number of pixels to increase the text's size with (negative number allowed).
*/
resizeFonts = function(i){  
  $$(els).each(function(e){
    e.prevSize = parseInt(e.getStyle('fontSize'), 10);
    if(!e.originalSize) { e.originalSize = e.prevSize; }
  });
  $$(els).each(function(e){
    setFontSize(e, e.prevSize + i);
  });
};

/*
* Increases the text size of all elements with 1px.
*/
upsizeFont = function(){
  resizeFonts(1);
};

/*
* Decreases the text size of all elements with 1px.
*/
downsizeFont = function(){
  resizeFonts(-1);
};

/*
* Resets the text size of all elements to its original size.
*/
resetFontSize = function(){
  $$(els).each(function(e){
    if(e.originalSize) { setFontSize(e, e.originalSize); }
  });
};

/*
* Initializes the text size of all elements to the size last set by the user.
*/
initFontSize = function(){
  var diff = jar.get('fontSizeDiff');
  if(diff) { resizeFonts(parseInt(diff, 10)); }
};

// Init font size when DOM has been fully loaded:
document.observe('dom:loaded', function() { 
    initFontSize();
});
