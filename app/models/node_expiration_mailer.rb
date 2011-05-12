class NodeExpirationMailer < UserMailer
  
  add_template_helper(ApplicationHelper)
    
  def author_notification(user, nodes, options = {})  
    set_defaults(user, options)

    @subject        = "Content onder uw beheer is verouderd."
    @body[:user]    = user
    @body[:nodes]    = nodes
  end
  
  def final_editor_notification(user, nodes, options = {})
    set_defaults(user, options)

    @subject        = "Content onder uw beheer werd niet tijdig geüpdated."
    @body[:user]    = user
    @body[:nodes]    = nodes
  end
end
