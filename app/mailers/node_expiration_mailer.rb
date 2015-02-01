# encoding: UTF-8
require 'ostruct'

class NodeExpirationMailer < UserMailer
  add_template_helper(ApplicationHelper)

  def author_notification(node, options = {})
    user = node.inherited_expiration_email_recipient
    user = OpenStruct.new(email_address: user, full_name: user) if user.is_a?(String)

    set_defaults(user, options)

    @subject = node.inherited_expiration_email_subject
    @user    = user
    @node    = node
    @text    = node.inherited_expiration_email_body

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def final_editor_notification(user, nodes, options = {})
    set_defaults(user, options)

    @subject = 'Content onder uw beheer werd niet tijdig geüpdatet.'
    @user    = user
    @nodes   = nodes

    mail(from: @from, to: @recipients, subject: @subject)
  end
end
