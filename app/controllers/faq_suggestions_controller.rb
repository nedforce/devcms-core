class FaqSuggestionsController < ApplicationController
  before_filter :find_theme

  def new
  end

  def create
    if FaqSuggestionsMailer.faq_suggestion(OpenStruct.new(
          theme:        @theme,
          question:     params[:question],
          explanation:  params[:explanation],
        )).deliver
      flash[:notice] = t('faq_suggestions.delivery_succeeded')
      redirect_to content_node_url(@theme)
    else
      flash[:error] = t('faq_suggestions.delivery_failed')
      redirect_to :back
    end
  end

  private
  def find_theme
    @theme = FaqTheme.find(params[:theme_id])
  end
end
