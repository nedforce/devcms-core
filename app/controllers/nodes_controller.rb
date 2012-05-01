# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Section+ objects.
class NodesController < ApplicationController

  def changes
    if @node.content_class != Feed && params[:format] == 'atom'
      if @node.has_changed_feed
        @nodes = @node.last_changes(:self)
      elsif @node.content_class <= Section
        @nodes = @node.last_changes(:all, { :limit => 25 })
      else
        raise ::AbstractController::ActionNotFound
      end
      
      respond_to do |format|
        format.atom { render :template => '/shared/changes', :layout => false }
      end
    else
      raise ::AbstractController::ActionNotFound
    end
  end  
  
private

  def find_node
    @node = current_site.self_and_descendants.accessible.include_content.find(params[:id])
  end

end
