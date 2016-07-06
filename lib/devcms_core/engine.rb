module DevcmsCore
  def self.config; DevcmsCore::Engine.config end

  class Engine < Rails::Engine
    config.model_paths = []
    config.layout_paths = []
    config.registered_models = []
    config.allowed_content_types_for_alphabetic_index = %w( Page )

    config.allow_content_node_routes = true
    config.reserved_slugs = ['admin', 'assets', 'signup']
    config.rewrite_paths = []
    config.rewriter = nil

    config.app_middleware.insert_before(Rack::Runtime, DevcmsCore::Rewriter)
    config.app_middleware.insert_before(Rack::Sendfile, ::ActionDispatch::Static, (self.root + 'public').to_s)

    # Cookies
    config.auth_token_cookie = :auth_token
    config.cookie_options = { httponly: true }
    config.signed_cookies = !Rails.env.test?
    config.refresh_auth_token_after_sign_out = true
    config.refresh_auth_token_after_password_reset = true
    config.refresh_auth_token_after_sign_in = false
    config.enforce_password_renewal = true
    config.renew_password_after = 3.months
    config.node_field_partials = []

    # Honeypot defaults
    config.honeypot_name       = 'OgJhm3UT'
    config.honeypot_value      = 'DA0MEHBTDZRQnTlv'
    config.honeypot_empty_name = 'eQ8oaGMk'
    config.honeypot_class      = 'ufnskjfdsniubh'

    # Airbrake configuration
    config.airbrake_redmine_project          = 'devcms'
    config.airbrake_development_environments = %w(development test cucumber)
    config.airbrake_redmine_host             = 'projects.nedforce.nl'
    config.airbrake_redmine_port             = 80
    config.airbrake_redmine_secure           = false
    config.airbrake_redmine_login            = 'exception_notifier'

    config.use_devcms_icons = true

    register_cms_modules

    initializer 'haml_configuration' do |app|
      Haml::Template.options[:format] = :xhtml
    end

    initializer 'exceptions_app' do |app|
      app.config.exceptions_app = app.routes
    end

    initializer 'register_cms_modules' do |app|
      config.model_paths.reverse.each do |model_path|
        config.registered_models += model_path.existent.map { |model| model.split('/').last[0..-4].camelize }
      end

      config.reserved_slugs += config.registered_models.map(&:tableize)
    end

    initializer 'devcms_precompile' do |app|
      app.config.assets.precompile += [
        'application.css',
        'admin.css',
        'pdf.css',
        'plain.css',
        'print.css',
        'ie.css',
        'templates/default.css'
      ]

      app.config.assets.precompile += [
        'devcms-core.js',
        'devcms_core_admin.js',
        'entropy.js',
        'ext/dvtr/*.js',
        'extjs.js',
        'i18n.js',
        'iepngfix_tilebg.js',
        'print.js',
        'admin/prototype16.js',
        'modules/ie8_text_content.js',
        'modules/ie9_create_contextual_fragment.js'
      ]

      app.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    end

    initializer 'data checker config' do |app|
      DataChecker.config.site_url = "http://#{Settler[:host]}" if SETTLER_LOADED && Settler[:host].present?
      DataChecker.config.checker_logger = DataChecker::DatabaseLogger
    end

    initializer 'airbrake configuration' do |app|
      Airbrake.configure do |config|
        config.api_key = {
          :project => DevcmsCore::Engine.config.airbrake_redmine_project,
          :api_key => DevcmsCore::Engine.config.airbrake_redmine_api_key
        }.to_yaml

        config.host   = DevcmsCore::Engine.config.airbrake_redmine_host
        config.port   = DevcmsCore::Engine.config.airbrake_redmine_port
        config.secure = DevcmsCore::Engine.config.airbrake_redmine_secure
        config.development_environments = DevcmsCore::Engine.config.airbrake_development_environments
      end
    end

    config.after_initialize do |app|
      # Process rewrites
      config.rewrite_paths.map(&:existent).flatten.reverse.each do |rewrites|
        require rewrites
      end
    end

    ActiveSupport.on_load(:action_controller) do
      include DevcmsCore::ActionControllerExtensions
      include DevcmsCore::RespondsToParent
      include DevcmsCore::RoutingHelpers
      include DevcmsCore::Recaptcha::Verify
    end

    ActiveSupport.on_load(:action_view) do
      include DevcmsCore::Recaptcha::ClientHelper
      include DevcmsCore::RoutingHelpers
    end

    ActiveSupport.on_load(:active_record) do
      include DevcmsCore::ActiveRecordExtensions
      include DevcmsCore::ActsAsCommentable
    end

    include DevcmsCore::ContentTypeConfiguration
  end
end
