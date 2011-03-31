module Rack
  class FacebookMethodFix

    def initialize(app)
      @app = app
    end

    def call(env)
      pp "BEFORE"
      pp env["REQUEST_METHOD"]
      if env["REQUEST_METHOD"] == "POST"
        req = Request.new(env)
        env["REQUEST_METHOD"] = "GET" if req.params[:signed_request]
      end
      pp "AFTER"
      pp env["REQUEST_METHOD"]

      @app.call(env)
    end
  end
  
end
