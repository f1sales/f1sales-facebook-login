require 'sinatra'
require 'http'

get '/auth/:provider/callback' do
  omniauth_auth = request.env['omniauth.auth']
  origin = request.env['omniauth.origin']
  credentials = omniauth_auth[:credentials] || {}
  token = credentials[:token]
  return redirect_to_failure(origin) unless token

  response = HTTP.post("#{origin}#{post_token_path}", json: { token: token })
  response.status == 200 ? redirect("#{origin}#{success_path}") : redirect_to_failure(origin)
end

get '/auth/failure' do
  redirect_to_failure(params[:origin])
end

def redirect_to_failure(url)
  redirect "#{url}#{failure_path}"
end

def failure_path
  '/auth/facebook/failure'
end

def success_path
  '/dashboard/integrations~facebook_page'
end

def post_token_path
  '/auth/facebook/token'
end
