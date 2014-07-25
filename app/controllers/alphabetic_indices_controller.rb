# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +AlphabeticIndex+ objects.
class AlphabeticIndicesController < ApplicationController
  
  helper AlphabeticIndexHelper  

  # The +show+ action needs a +AlphabeticIndex+ object to work with.
  before_filter :find_alphabetic_index, :only => [ :show, :letter ]
  before_filter :find_pages,            :only => [ :show, :letter ]

  # * GET /alphabetic_indices/:id
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # * GET /alphabetic_indices/:id/:letter
  def letter
    respond_to do |format|
      format.html { render :show }
    end
  end

  protected

  # Finds the +AlphabeticIndex+ object corresponding to the passed in +id+ parameter.
  def find_alphabetic_index
    @alphabetic_index = @node.content
  end

  def find_pages
    @letter = params[:letter] || 'A'
    @items  = @alphabetic_index.items(@letter)
  end
end
