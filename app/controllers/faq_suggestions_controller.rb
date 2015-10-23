class FaqSuggestionsController < ApplicationController
  before_filter :find_theme

  def new
  end

  def create
    if suggestion_valid? &&
      FaqSuggestionsMailer.faq_suggestion(OpenStruct.new(
          theme:        @theme,
          question:     params[:question],
          explanation:  params[:explanation],
          email:  params[:email]
      )).deliver

      flash[:notice] = t('faq_suggestions.delivery_succeeded')
      redirect_to content_node_url(@theme)
    else
      flash[:error] = (t('faq_suggestions.delivery_failed') + render_error_list).html_safe
      render :new
    end
  end

  private

  def find_theme
    @theme = FaqTheme.find(params[:theme_id])
  end

  def suggestion_valid?
    @errors = []
    validate_presence
    validate_email
    @errors.none?
  end

  def render_error_list
    error_list = @errors.map { |error| "<li> #{error} </li>" }.join.html_safe
    "<ul> #{error_list} </ul>".html_safe
  end

  def validate_presence
    [:question, :explanation, :email].each do |attr|
      if params[attr].blank?
        @errors << t('faq_suggestions.errors.presence', attribute: t(attr, scope: 'faq_suggestions'))
      end
    end
  end

  def validate_email
    return if params[:email] =~ EmailValidator::REGEX

    @errors << t('faq_suggestions.errors.email_invalid')
  end
end
