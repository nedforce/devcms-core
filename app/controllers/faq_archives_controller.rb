class FaqArchivesController < ApplicationController
  def show
    @faq_archive = @node.content

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
