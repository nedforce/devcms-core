# Sass options
Sass::Plugin.options[:load_paths] = ['./app/stylesheets/imports']
Sass::Plugin.add_template_location('./app/stylesheets/application', './public/stylesheets')
Sass::Plugin.add_template_location('./app/stylesheets/templates', './public/stylesheets')

Dir["#{RAILS_ROOT}/vendor/plugins/devcms-*"].each do |devcms_engine|
  engine_name = devcms_engine.gsub("#{RAILS_ROOT}/vendor/plugins/devcms-",'')
  Sass::Plugin.options[:load_paths] << "./vendor/plugins/devcms-#{engine_name}/app/stylesheets/imports"
  Sass::Plugin.add_template_location("./vendor/plugins/devcms-#{engine_name}/app/stylesheets/application", './public/stylesheets')
end
