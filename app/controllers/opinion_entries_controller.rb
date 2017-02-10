class OpinionEntriesController < ApplicationController
  before_action :find_opinion
    
  def new
    @opinion_entry = OpinionEntry.new(permitted_attributes)
  end

  def create
    @opinion_entry = OpinionEntry.new
    @opinion_entry.feeling = params[:feeling].to_i
    @opinion_entry.description = params[:description] || 0
    @opinion_entry.text = params[:text] || ''
    @opinion_entry.opinion_id = @opinion.id
    @opinion_entry.save!
    redirect_to content_node_path(@opinion.parent)
  end

  protected

  def permitted_attributes
    params.fetch(:opinion_entry, {}).permit!
  end
  
  def find_opinion
    @opinion = Opinion.find(params[:opinion_id])
    @redirectnode = Node.find(params[:node_id])
    @feeling = params[:feeling]
  end
end
