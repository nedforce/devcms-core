# Recommended secure headers configuration, copied from
# https://github.com/twitter/secureheaders.
#
# Note that not all methods are called in the application controller.
SecureHeaders::Configuration.default do |config|
  if Rails.env.production? && DevcmsCore.config.ssl_enabled
    config.hsts = "max-age=#{20.years.to_i}"
  else
    config.hsts = 'max-age=0'
  end

  # Cannot use 'DENY', because the upload functionality in the back-end
  # uses iframes.
  config.x_frame_options = 'SAMEORIGIN'

  config.x_content_type_options = 'nosniff'
  config.x_xss_protection = '1; mode=block'
  config.x_download_options = SecureHeaders::OPT_OUT
  config.x_permitted_cross_domain_policies = SecureHeaders::OPT_OUT
  config.csp = SecureHeaders::OPT_OUT
end
