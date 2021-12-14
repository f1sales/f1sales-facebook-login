ENV['RACK_ENV'] = 'test'
ENV['SECRET_KEY_BASE'] = 'abc123'

require 'rack/test'
require 'rspec'
require 'faker'
require 'webmock/rspec'
require 'byebug'
require 'omniauth-facebook'

require_relative '../f1sales_facebook_login'

module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
end
