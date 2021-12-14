require 'bundler/setup'
require 'omniauth-facebook'
require './f1sales_facebook_login'

use Rack::Session::Cookie, secret: ENV['SECRET_KEY_BASE']

use OmniAuth::Builder do
  provider :facebook,
    ENV['FACEBOOK_KEY'],
    ENV['FACEBOOK_SECRET'],
    scope: 'manage_pages,leads_retrieval',
    origin_param: 'return_to',
    client_options: {
      site: 'https://graph.facebook.com/v3.3',
      authorize_url: 'https://www.facebook.com/v3.3/dialog/oauth'
    }
end

run Sinatra::Application
