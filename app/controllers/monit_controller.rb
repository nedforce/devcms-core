class MonitController < ApplicationController
  layout false
  
  skip_before_filter :login_from_cookie
  skip_before_filter :find_node
  
  def heartbeat
    render :text => ""
  end
end
