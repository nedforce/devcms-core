require File.dirname(__FILE__) + '/../test_helper'

class ResponsesControllerTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @help_form = contact_forms(:help_form)
  end
  
 
  
end
