# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# Create a root node
root_section = Site.create!(:title => 'Website', :description => 'Your website')
root_section.node.update_attributes!(:layout => "deventer", :layout_variant => 'default', :layout_configuration => {'template_color'=>'default'})

# Create an admin
u = User.create!(:login => 'webmaster', :email_address => "webmaster@example.com", :password => 'admin', :password_confirmation => 'admin')
u.update_attribute(:verified, true)
u.give_role_on('admin', Node.root)
