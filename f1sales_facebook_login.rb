require 'sinatra'
require 'byebug'
require 'http'
require 'haml'

set :sessions, true

get '/:store_id' do
  @store_id = params[:store_id]
  haml :start
end

get '/auth/:provider/callback' do
  omniauth_auth = request.env['omniauth.auth']
  origin = request.env['omniauth.origin']
  credentials = omniauth_auth[:credentials]
  token = credentials[:token]
  response = HTTP.post(origin, json: { token: token })
  puts response
  redirect JSON.parse(response.body)['redirect']
end
