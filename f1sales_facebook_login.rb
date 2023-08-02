require 'sinatra'
require 'http'
require 'omniauth'
require 'omniauth-mercadolibre'
require 'omniauth-facebook'

get '/auth/:provider/callback' do
  origin = request.env['omniauth.origin']
  return redirect_to_failure(origin) unless token

  response = HTTP.post("#{origin}#{post_token_path}", json: json_payload)
  response.status == 200 ? redirect("#{origin}#{success_path}") : redirect_to_failure(origin)
end

get '/auth/failure' do
  redirect_to_failure(params[:origin])
end

get '/health' do
  status 200
end

private

def redirect_to_failure(url)
  redirect "#{url}#{failure_path}"
end

def failure_path
  '/auth/facebook/failure'
end

def success_path
  if facebook?
    '/dashboard/integrations~facebook_page'
  elsif mercado_livre?
    '/dashboard/integrations~mercado_livre'
  end
end

def post_token_path
  if facebook?
    '/auth/facebook/token'
  elsif mercado_livre?
    '/auth_mercado_livre'
  end
end

def json_payload
  if facebook?
    { token: token }
  elsif mercado_livre?
    {
      user_id: omniauth_auth[:uid],
      access_token: token,
      refresh_token: credentials[:refresh_token]
    }
  end
end

def provider
  params[:provider]
end

def omniauth_auth
  request.env['omniauth.auth']
end

def credentials
  omniauth_auth[:credentials] || {}
end

def token
  credentials[:token]
end

def facebook?
  provider == 'facebook'
end

def mercado_livre?
  provider == 'mercadolibre'
end

OmniAuth::Strategies::MercadoLibre.class_eval do
  def query_string
    ''
  end
end
