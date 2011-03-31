module Rack
  class FacebookMethodFix

    def initialize(app)
      @app = app
    end

    def call(env)
      if env["REQUEST_METHOD"] == "POST"
        req = Request.new(env)
        env["REQUEST_METHOD"] = "GET" if req.params["signed_request"]
      end
      @app.call(env)
    end
    
  end
  
end
