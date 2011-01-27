Dir["#{RAILS_ROOT}/vendor/plugins/*/initializer.rb"].each { |initializer| require initializer }

# Ensure application translations have precedence
I18n.load_path = I18n.load_path.reverse