# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Theme+ objects.
class ThemesController < ApplicationController

  # The +show+ action needs a +Theme+ object to work with.
  before_filter :find_theme, :only => :show

  protected

  # Finds the +Theme+ object corresponding to the passed +id+ parameter.
  def find_theme
    @theme = @node.content
  end
end
