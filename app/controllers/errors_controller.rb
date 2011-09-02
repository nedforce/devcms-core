class ErrorsController < ApplicationController
  skip_before_filter :find_node
  
  skip_before_filter :find_context_node
  
  skip_before_filter :check_authorization
  
  def error_404
    respond_to do |f|
      f.html do
        if (error_404_url_alias = Settler[:error_page_404]).present? && @node = Node.find_by_url_alias(error_404_url_alias)
          @page = @node.content
          render :template => 'pages/show', :status => :not_found
        else
          render :action => "404", :status => :not_found
        end
      end
    end
  end
  
  def error_500
    respond_to do |f|
      f.html do
        if (error_500_url_alias = Settler[:error_page_500]).present? && @node = Node.find_by_url_alias(error_500_url_alias)
          @page = @node.content
          render :template => 'pages/show', :status => :internal_server_error
        else
          render :action => "500", :status => :internal_server_error
        end
      end
    end
  end
  
protected

  def set_page_title
    @page_title = case action_name
      when "error_404" : t('errors.page_not_found')
      when "error_500" : t('errors.internal_server_error')
      else ""
    end
  end
  
end