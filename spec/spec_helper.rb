$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'erector_cache'
require 'spec'
require 'spec/autorun'
require "lawnchair"
LAWNCHAIR = Lawnchair
LAWNCHAIR.connectdb(Redis.new(:db => 3))

Spec::Runner.configure do |config|
  config.before(:each) do
    LAWNCHAIR.flushdb
  end
end

class FixtureTemplate < ActionView::Base

  def initialize
    ActionView::Base.module_eval do
      def protect_against_forgery?
        false
      end
    end
    @controller = ActionController::Base.new
    @controller.logger = Logger.new("/tmp/foo")
    request = create_request
    response = create_response
    @controller.send(:assign_shortcuts, request, response)
    @controller.instance_variable_set(:@url, ActionController::UrlRewriter.new(request, {}))
    if respond_to?(:output_buffer)
      self.output_buffer = ""
    end
  end

  def controller
    @controller
  end

  def create_request
    env = {}
    env['REQUEST_URI'] = "/foo"
    env['action_controller.request.request_parameters'] = {}
    ActionController::Request.new(env)
  end

  def create_response
    response = ActionController::Response.new
    response.template = ActionView::Base.new([],{},controller)
    response
  end
end

def render_template
  @output = yield FixtureTemplate.new.controller
end
