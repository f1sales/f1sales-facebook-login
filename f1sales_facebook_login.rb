require 'sinatra'
require 'http'
require 'omniauth'
require 'omniauth-mercadolibre'
require 'omniauth-facebook'

configure :production, :development do
  enable :logging
  $stdout.sync = true # Toda saída será exibida assim que solicitada, independente do buffer.
end

get '/auth/:provider/callback' do
  omniauth_auth = request.env['omniauth.auth']
  origin = request.env['omniauth.origin']
  credentials = omniauth_auth[:credentials] || {}
  token = credentials[:token]
  logger.info "Token TMNT -> #{token}"
  return redirect_to_failure(origin) unless token

  response = HTTP.post("#{origin}#{post_token_path(params[:provider])}", json: { token: token })
  response.status == 200 ? redirect("#{origin}#{success_path(params[:provider])}") : redirect_to_failure(origin)
end

get '/auth/failure' do
  redirect_to_failure(params[:origin])
end

get '/health' do
  status 200
end

def redirect_to_failure(url)
  redirect "#{url}#{failure_path}"
end

def failure_path
  '/auth/facebook/failure'
end

def success_path(provider)
  if provider == 'facebook'
    '/dashboard/integrations~facebook_page'
  elsif provider == 'mercadolibre'
    '/dashboard/integrations~mercado_livre'
  end
end

def post_token_path(provider)
  if provider == 'facebook'
    '/auth/facebook/token'
  elsif provider == 'mercadolibre'
    '/mercado_livre/token'
  end
end

OmniAuth::Strategies::MercadoLibre.class_eval do
  def query_string
    ''
  end
end
