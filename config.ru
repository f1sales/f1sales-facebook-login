require 'bundler/setup'
require 'omniauth-facebook'
require './f1sales_facebook_login'

use Rack::Session::Cookie, secret: ENV['SECRET_KEY_BASE']

use OmniAuth::Builder do
  provider :facebook,
    ENV['FACEBOOK_KEY'],
    ENV['FACEBOOK_SECRET'],
    scope: 'manage_pages,leads_retrieval',
    origin_param: 'return_to'
end

OmniAuth.config.on_failure = proc { |env| OmniAuth::FailureEndpoint.new(env).redirect_to_failure }

run Sinatra::Application
