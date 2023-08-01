require 'bundler/setup'
require 'omniauth-facebook'
require 'omniauth-mercadolibre'
require './f1sales_facebook_login'

use Rack::Logger

use Rack::Session::Cookie, secret: ENV['SECRET_KEY_BASE']

use OmniAuth::Builder do
  provider :facebook,
           ENV['FACEBOOK_KEY'],
           ENV['FACEBOOK_SECRET'],
           scope: 'pages_manage_metadata,pages_read_engagement,pages_manage_ads,leads_retrieval',
           origin_param: 'return_to'
  provider :mercadolibre, '6282907391852569', 'k53k3JRTJgIliZdfiRY72eiQMgx1c3m3', origin_param: 'return_to'
end

OmniAuth.config.on_failure = proc { |env| OmniAuth::FailureEndpoint.new(env).redirect_to_failure }

run Sinatra::Application
