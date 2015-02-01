class FaqSuggestionsMailer < ActionMailer::Base
  def faq_suggestion(faq_suggestion, options = {})
    @recipients  = Settler[:faq_mail_recipient]
    @from        = faq_suggestion.email || Settler[:mail_from_address]
    @sent_on     = Time.zone.now
    @subject     = t('faqs.suggestion_for', theme: faq_suggestion.theme.title)
    @host        = options[:host] || Settler[:host]
    @question    = faq_suggestion.question
    @explanation = faq_suggestion.explanation
    @url         = admin_nodes_path(active_node_id: faq_suggestion.theme.node.id)

    mail(from: @from, to: @recipients, subject: @subject)
  end
end
