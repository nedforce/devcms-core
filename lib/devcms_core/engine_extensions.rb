module DevcmsCore
  module EngineExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      def register_cms_modules
        config.model_paths   << paths.add('app/models/*',    :with => 'app/models',  :glob => '*.rb')
        config.layout_paths  << paths.add('app/layouts/*',   :with => 'app/layouts', :glob => '*')
        config.rewrite_paths << paths.add('config/rewrites', :with => 'config/rewrites.rb')
      end
    end
  end
end
