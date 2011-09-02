class MonitController < ApplicationController
  layout false
  
  skip_before_filter :login_from_cookie
  
  def heartbeat
    render :text => ""
  end
end
