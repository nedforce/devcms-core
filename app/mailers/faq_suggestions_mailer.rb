class FaqSuggestionsMailer < ActionMailer::Base
  def faq_suggestion(faq_suggestion)
    @recipients            = "webredactie@deventer.nlwebredactie@deventer.nl"
    @from                  = faq_suggestion.email || Settler[:mail_from_address]
    @sent_on               = Time.now
    @subject               = t('faqs.suggestion_for', theme: faq_suggestion.theme.title)
    @question              = faq_suggestion.question
    @explanation           = faq_suggestion.explanation
    @url                   = admin_nodes_path(:active_node_id => faq_suggestion.theme.node.id)

    mail(:from => @from, :to => @recipients, :subject => @subject)
  end
end
