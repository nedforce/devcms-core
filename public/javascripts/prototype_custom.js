/*
 *  Overrides Prototype's Element.update() function to favor DOM techniques for updating
 *  element contents instead of using the innerHTML property.
 *
 *--------------------------------------------------------------------------*/

Element.Methods.update = function (element, content) {
  element = $(element);

  if (content && content.toElement) { content = content.toElement(); }
  if (Object.isElement(content)) { return element.update().insert(content); }

  content = Object.toHTML(content);

  // createContextualFragment is broken in WebKit and Opera, so we have to fall back to innerHTML for WebKit-based browsers and Opera
  if (document.createRange && !Prototype.Browser.WebKit && !Prototype.Browser.Opera) {
    var DOMrng, DOMhtmlFrag;

    DOMrng = document.createRange();
    DOMhtmlFrag = DOMrng.createContextualFragment(content.stripScripts());
    while (element.hasChildNodes()) {
      element.removeChild(element.lastChild);
    }
    element.appendChild(DOMhtmlFrag);
  } else {
    element.innerHTML = content.stripScripts();
  }

  content.evalScripts.bind(content).defer();
  return element;
};
