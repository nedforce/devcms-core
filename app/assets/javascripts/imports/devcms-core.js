/*global document,$,$$,Ajax*/
document.observe('dom:loaded', function () {
  javascriptifyLogoutLinks();
  javascriptifyUnsubscribeNewsletterArchiveLinks();
  javascriptifyDeleteWeblogLinks();
  javascriptifyDeleteWeblogPostLinks();
  javascriptifyToggableSectionLinks();
  ajaxifyPollSideBoxElements();
  ajaxifyNewsletterArchiveSideBoxElements();
  showFontResizeBox();
});

function javascriptifyToggableSectionLinks() {
  $$('.toggable_section_link').each(function (link) {
    link.addClassName('activated');
    $(link.id.replace('toggle_section_', '')).hide();

    link.observe('click', function (event) {
      var section_id = $(this).id.replace('toggle_section_', '');
      Effect.toggle(section_id, 'appear', { duration: 0.5 });
      Element.toggleClassName(link.id, 'minus_icon');
      Event.stop(event);
    });
  });
}

function javascriptifyLogoutLinks() {
  $$('a.logout').each(function (anchor) {
    attachDeleteFormToAnchor(anchor, true); // second arg to true for no confirmation
  });
}

function javascriptifyUnsubscribeNewsletterArchiveLinks() {
  $$('a.unsubscribe_newsletter_archive').each(function (anchor) {
    attachDeleteFormToAnchor(anchor);
  });
}

function javascriptifyDeleteWeblogLinks() {
  $$('a.delete_weblog').each(function (anchor) {
    attachDeleteFormToAnchor(anchor);
  });
}

function javascriptifyDeleteWeblogPostLinks() {
  $$('a.delete_weblog_post').each(function (anchor) {
    attachDeleteFormToAnchor(anchor);
  });
}

function attachDeleteFormToAnchor(anchor, no_confirmation) {
  anchor.observe('click', function (event) {
    if (no_confirmation || confirm('Weet u het zeker?')) {
      var f, m, s;

      f = document.createElement('form');
      f.style.display = 'none';
      anchor.parentNode.appendChild(f);
      f.method = 'POST';
      f.action = anchor.href;

      m = document.createElement('input');
      m.setAttribute('type', 'hidden');
      m.setAttribute('name', '_method');
      m.setAttribute('value', 'delete');
      f.appendChild(m);

      s = document.createElement('input');
      s.setAttribute('type', 'hidden');
      s.setAttribute('name', 'authenticity_token');
      s.setAttribute('value', AUTH_TOKEN);
      f.appendChild(s);
      f.submit();
    }

    event.stop();
  });
}

function ajaxifyNewsletterArchiveSideBoxElements() {
  $$('form.newsletter_archive_content_box_form').each(function (form) {
    ajaxifyNewsletterArchiveSideBoxElementForm(form.id);
  });
}

function ajaxifyNewsletterArchiveSideBoxElementForm(id) {
  var form, buttons, image, link;

  form = $(id);
  buttons = form.down('div.buttons');

  if (form.hasClassName('unsubscribe')) {
    buttons.down('input.unsubscribe_button').addClassName('hidden');

    image = new Element('img', {
      'src': I18n.t('unsubscribe_image', 'newsletter_archives'),
      'alt': I18n.t('unsubscribe_alt', 'newsletter_archives'),
      'title': I18n.t('unsubscribe_title', 'newsletter_archives')
    });

    link = new Element('a', {
      'href': '#'
    }).update(I18n.t('unsubscribe', 'newsletter_archives'));

    link.observe('click', function (event) {
      new Ajax.Request(form.action, {
        asynchronous: true,
        evalScripts: true,
        method: 'delete',
        parameters: form.serialize(),
        onComplete: function (response) {
          ajaxifyNewsletterArchiveSideBoxElementForm(id);
        }
      });

      event.stop();
    });

    buttons.insert(image);
    buttons.insert(link);

    image.addClassName('icon transparent');
    link.addClassName('unsubscribe_link');
  } else {
    buttons.down('input.subscribe_button').addClassName('hidden');

    image = new Element('img', {
      'src': I18n.t('subscribe_image', 'newsletter_archives'),
      'alt': I18n.t('subscribe_alt', 'newsletter_archives'),
      'title': I18n.t('subscribe_title', 'newsletter_archives')
    });

    link = new Element('a', {
      'href': '#'
    }).update(I18n.t('subscribe', 'newsletter_archives'));

    link.observe('click', function (event) {
      new Ajax.Request(form.action, {
        asynchronous: true,
        evalScripts: true,
        method: 'post',
        parameters: form.serialize(),
        onComplete: function (response) {
          ajaxifyNewsletterArchiveSideBoxElementForm(id);
        }
      });

      event.stop();
    });

    buttons.insert(image);
    buttons.insert(link);

    image.addClassName('icon transparent');
    link.addClassName('subscribe_link');
  }
}

function ajaxifyPollSideBoxElements() {
  $$('.poll_content_box_form').each(function (form) {
    var buttons, resultsLink, voteLinkContainer, image, voteLink;

    buttons = form.down('.buttons');

    if (buttons.down('.login_link') == null) {
      buttons.down('.vote_button').addClassName('hidden');

      resultsLink = buttons.down('.results_link');
      resultsLink.observe('click', function (event) {
        new Ajax.Request(resultsLink.href, {
          asynchronous: true,
          evalScripts: true,
          method: 'get'
        });

        event.stop();
      });

      voteLinkContainer = new Element('div', { 'class': 'vote' });

      image = new Element('img', {
        'src': I18n.t('submit_image', 'polls'),
        'alt': '',
        'title': I18n.t('submit_title', 'polls')
      });

      voteLink = new Element('a', {
        'href': '#'
      });

      voteLink.update(I18n.t('submit', 'polls'));

      voteLink.observe('click', function (event) {
        new Ajax.Request(form.action, {
          asynchronous: true,
          evalScripts: true,
          method: 'post',
          parameters: form.serialize()
        });

        event.stop();
      });

      voteLinkContainer.insert(image);
      voteLinkContainer.insert(voteLink);

      image.addClassName('icon transparent');
      voteLink.addClassName('vote_link');

      buttons.insert(voteLinkContainer);
    }
  });
}

function showFontResizeBox() {
  var fontResizeBox, smallerFontLink, smallerFontImage, biggerFontLink, biggerFontImage;

  fontResizeBox = $('fontsize');

  if (fontResizeBox) {
    smallerFontLink = new Element('a', {
      'href': '#',
      'title': I18n.t('smaller_text_title', 'font_resize')
    });

    smallerFontImage = new Element('img', {
      'src': I18n.t('smaller_text_image', 'font_resize'),
      'alt': I18n.t('smaller_text', 'font_resize'),
      'class': 'transparent'
    });

    biggerFontLink = new Element('a', {
      'href': '#',
      'title': I18n.t('bigger_text_title', 'font_resize')
    });

    biggerFontImage = new Element('img', {
      'src': I18n.t('bigger_text_image', 'font_resize'),
      'alt': I18n.t('bigger_text', 'font_resize'),
      'class': 'transparent'
    });

    smallerFontLink.insert(smallerFontImage);
    biggerFontLink.insert(biggerFontImage);

    smallerFontLink.observe('click', downsizeFont);
    biggerFontLink.observe('click', upsizeFont);

    [ smallerFontLink, biggerFontLink ].each(function (image) {
      fontResizeBox.insert(image);
    });

    fontResizeBox.removeClassName('hidden');
  }
}
