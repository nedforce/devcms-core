# Tell the I18n library where to find the translation files.
I18n.load_path.push(*Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')])

# Set default locale to something other than :en
I18n.locale = :nl
I18n.default_locale = :nl

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!({
  :long => "%e %B %Y"
})