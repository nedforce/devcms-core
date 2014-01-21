I18n.enforce_available_locales = true

# Tell the I18n library where to find the translation files.
I18n.load_path += Dir[DevcmsCore::Engine.root.join('config', 'locales', '*')]

# Set default locale to something other than :en
I18n.locale = :nl
I18n.default_locale = :nl
