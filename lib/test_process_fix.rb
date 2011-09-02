#Make sure all functional test requests go through our custom route recognition mechanism
module ActionController #:nodoc:
  module TestProcess #:nodoc:
    def process(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      # Sanity check for required instance variables so we can give an
      # understandable error message.
      %w(@request @response).each do |iv_name|
        if !(instance_variable_names.include?(iv_name) || instance_variable_names.include?(iv_name.to_sym)) || instance_variable_get(iv_name).nil?
          raise "#{iv_name} is nil: make sure you set it in your test's setup method."
        end
      end

      @request.recycle!
      @response.recycle!

      @html_document = nil
      @request.env['REQUEST_METHOD'] = http_method

      @request.action = action.to_s

      parameters ||= {}
      @request.assign_parameters(@controller.class.controller_path, action.to_s, parameters)

      @request.session = ActionController::TestSession.new(session) unless session.nil?
      @request.session["flash"] = ActionController::Flash::FlashHash.new.update(flash) if flash

      # Prevent caching of the REQUEST_URI, somehow the cached value is sometimes wrong
      @request.set_REQUEST_URI(nil)

      build_request_uri(action, parameters)
  
      ActionController::Base.class_eval { include ActionController::ProcessWithTest } unless ActionController::Base < ActionController::ProcessWithTest
      
      # Go through the route recognition mechanism, instead of directly calling the controller that's associated with the functional test
      klass = ActionController::Routing::Routes.recognize(@request)
            
      @controller = klass.new
      @controller.process_with_test(@request, @response)
    end
  end
end