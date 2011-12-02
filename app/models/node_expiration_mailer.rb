require 'ostruct'
class NodeExpirationMailer < UserMailer
  
  add_template_helper(ApplicationHelper)
    
  def author_notification(node, options = {})
    user = node.inherited_expiration_email_recipient
    user = OpenStruct.new(:email_address => user, :full_name => user) if user.is_a?(String)
    
    set_defaults(user, options)

    @subject      = node.inherited_expiration_email_subject
    @body[:user]  = user
    @body[:node]  = node
    @body[:text]  = node.inherited_expiration_email_body
  end
  
  def final_editor_notification(user, nodes, options = {})
    set_defaults(user, options)

    @subject        = "Content onder uw beheer werd niet tijdig geüpdated."
    @body[:user]    = user
    @body[:nodes]   = nodes
  end
end
