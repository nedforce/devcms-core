# Create a root node
root_section = Site.create!(title: 'Website', description: 'Your website')
root_section.node.update_attributes!(layout: 'default', layout_variant: 'default', layout_configuration: { 'template_color' => 'default' })

# Create an admin
u = PrivilegedUser.create!(login: 'webmaster', email_address: 'webmaster@example.com', password: 'admin', password_confirmation: 'admin')
u.update_attribute(:verified, true)
u.give_role_on('admin', Node.root)
