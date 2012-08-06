module DevcmsCore
  class MeasureQueuing
    
    def initialize(app)
      @app = app       
    end                

    def call(env)
      env["X-Queue-Start"] = "t=#{(Time.now.to_f * 1000000).to_i}"
      @app.call(env)   
    end                
  end                  
end