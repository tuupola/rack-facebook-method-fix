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
end