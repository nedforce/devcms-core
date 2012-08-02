module DevcmsCore
  
  class Engine < Rails::Engine
    config.model_paths = []
    config.layout_paths = []
    config.registered_models = []
    config.allowed_content_types_for_alphabetic_index = %w( Page )
    
    config.reserved_slugs = ['admin', 'assets']
    config.rewrite_paths = []
    config.rewriter = nil

    config.app_middleware.insert_before(Rack::Lock, DevcmsCore::Rewriter)
    config.app_middleware.insert_before(::DevcmsCore::Rewriter, DevcmsCore::MeasureQueuing)
    config.app_middleware.insert_before(::DevcmsCore::Rewriter, ::ActionDispatch::Static, "#{root}/public") 

    register_cms_modules        
    
    initializer "exceptions_app" do |app|
      app.config.exceptions_app = app.routes
    end

    initializer "register_cms_modules" do |app|
      config.model_paths.reverse.each do |model_path| 
        config.registered_models += model_path.existent.collect{|model| model.split('/').last[0..-4].camelize }
      end
      
      config.reserved_slugs += config.registered_models.collect(&:tableize)
    end
    
    initializer "devcms_precompile" do |app|
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
        'devcms_core.js',
        'devcms_core_admin.js',
        'entropy.js',
        'ext/dvtr/*.js',
        'extjs.js',
        'i18n.js',
        'iepngfix_tilebg.js',
        'placeholder.js',
        'print.js',
        'search.js',
        'treemenu.js'
      ]
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