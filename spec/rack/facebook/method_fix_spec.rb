require File.expand_path('spec_helper', File.join(File.dirname(__FILE__), '../../'))

class MockRackWrapper
  def initialize(response)
    @response = response
  end

  def call(env)
    @env = env
    @response
  end

  def env
    @env
  end
end

describe Rack::Facebook::MethodFix do
  context "with no exclusions" do
    before do
      header = [200, {"Content-type" => "test/plain", "Content-length" => "5"}, ["foo"]]
      @rack_mock = MockRackWrapper.new(header)
      facebook = Rack::Facebook::MethodFix.new(@rack_mock)
      @request = Rack::MockRequest.new(facebook)
    end

    context "POST requests not from facebook" do
      it 'should stay as a POST' do
        @request.post("/", {})

        @rack_mock.env["REQUEST_METHOD"].should == "POST"
      end
    end

    context 'POST requests from facebook' do
      it 'should be changed to GET requests' do
        @request.post("/", {:params => {"signed_request" => 'nothing'}})

        @rack_mock.env["REQUEST_METHOD"].should == "GET"
      end
    end
  end

  context 'when the middleware is passed an exclusion proc' do
    before do
      simple_response = [200, {"Content-type" => "test/plain", "Content-length" => "5"}, ["foo"]]
      @mock_rack_app = MockRackWrapper.new(simple_response)
      exclusion_proc = proc { |env| env['PATH_INFO'].match(/^\/admin/) }
      facebook_method_fix_app = Rack::Facebook::MethodFix.new(@mock_rack_app, :exclude => exclusion_proc)
      @request = Rack::MockRequest.new(facebook_method_fix_app)
    end

    it "does not change requests that are not from facebook" do
      @request.post('/', {})
      @mock_rack_app.env["REQUEST_METHOD"].should == "POST"
    end

    context "requests from facebook " do
      let(:params) { {:params => {"signed_request" => 'nothing'}} }
      it "changes POSTs to GETs the exclusion proc returns false" do
        @request.post('/foo', params)
        @mock_rack_app.env["REQUEST_METHOD"].should == "GET"
      end

      it "does not change POSTs when the exclusion proc returns true" do
        @request.post('/admin/foo', params)
        @mock_rack_app.env["REQUEST_METHOD"].should == "POST"
      end
    end
  end
end