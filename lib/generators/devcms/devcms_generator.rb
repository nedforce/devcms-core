# Generates some files for creating a new devcms app
# Documentation: http://rdoc.info/github/wycats/thor/master/Thor/Actions
class DevcmsGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  def install_devcms
    directory 'app', '.'
  end
end
