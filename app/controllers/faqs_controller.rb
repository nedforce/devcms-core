class FaqsController < ActionController::Metal
  include ActionController::Redirecting

  def show
    if request.xhr?
      status = 200
    else
      redirect_to "#{request.env["HTTP_REFERER"]}##{Faq.find(params[:id]).to_link_name}"
    end
    Faq.increment_counter :hits, params[:id]
  end
end
