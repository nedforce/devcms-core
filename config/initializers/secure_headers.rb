# Recommended secure headers configuration, copied from
# https://github.com/twitter/secureheaders.
#
# Note that not all methods are called in the application controller.
SecureHeaders::Configuration.default do |config|
  if Rails.env.production?
    config.hsts = { max_age: 20.years.to_i }
  else
    config.hsts = { max_age: 0 }
  end

  # Cannot use 'DENY', because the upload functionality in the back-end
  # uses iframes.
  config.x_frame_options = 'SAMEORIGIN'

  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = '1; mode=block'
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = 'none'
  config.csp = {
    default_src: %w(https: 'self'),
    report_only: false,
    frame_src: %w('self' *.twimg.com itunes.apple.com),
    connect_src: %w(wws:),
    font_src: %w('self' data:),
    img_src: %w(mycdn.com data:),
    media_src: %w(utoob.com),
    object_src: %w('self'),
    script_src: %w('self'),
    style_src: %w('unsafe-inline'),
    base_uri: %w('self'),
    child_src: %w('self'),
    form_action: %w('self' github.com),
    frame_ancestors: %w('none'),
    plugin_types: %w(application/x-shockwave-flash),
    block_all_mixed_content: true, # see [http://www.w3.org/TR/mixed-content/](http://www.w3.org/TR/mixed-content/)
    report_uri: %w(https://example.com/uri-directive)
  }
  config.hpkp = {
    report_only: false,
    max_age: 60.days.to_i,
    include_subdomains: true,
    report_uri: 'https://example.com/uri-directive',
    pins: [
      { sha256: 'abc' },
      { sha256: '123' }
    ]
  }
end
