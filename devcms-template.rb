# Init git repository
git :init

# Install the Engines plugin
plugin 'engines', :git => 'git://github.com/lazyatom/engines.git'

# Add the devcms submodule
git :submodule => 'add git://github.com/nedforce/devcms-core.git vendor/plugins/devcms-core'
run 'cd vendor/plugins/devcms-core; git checkout 1.0.1'

# Install devcms
rake('devcms:install')

# Copy database.yml for distribution use
run "cp config/database.example.yml config/database.yml"

# Set up .gitignore files
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
vendor/rails
END

# Remove broken initializer
run "rm config/initializers/cookie_verification_secret.rb"

# Final install steps
rake('gems:install')

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'Initial commit'"

# Success!
puts "Success! Now, configure your database in config/database.yml, create the database using 'rake db:create' and finally run 'rake db:migrate'."
puts "Afterwards, you can populate your database by running 'rake db:populate:all'."
