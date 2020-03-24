# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'workos'
require 'rack/ssl-enforcer'
require 'securerandom'
require 'faker'

use Rack::SslEnforcer if production?
set :session_secret, ENV['SESSION_SECRET'] || SecureRandom.hex(32)

use(Rack::Session::Cookie, 
  :key => '_rack_session',
  :path => '/',
  :expire_after => 2592000,
  :secret => settings.session_secret
)

get '/' do
  company_name = params['company'] || Faker::Internet.domain_word
  domain = company_name + '.com'
  @current_user = {
    id: SecureRandom.uuid,
    email: "demo@#{domain}",
    name: 'Demo User',
    account: {
      id: SecureRandom.uuid,
      name: company_name,
      domain: domain,
    }
  }

  puts @current_user
  erb :index, :layout => :layout
end

post '/confirm' do
  WorkOS::SSO.promote_draft_connection(
    token: params['token'],
  )
end

get '/sso' do
  @current_user = session[:user] && JSON.pretty_generate(session[:user])
  @email = params['email']
  erb :login, :layout => :layout
end

post '/sso/login' do
  domain = params['email'].split('@')[1].downcase
  
  authorization_url = WorkOS::SSO.authorization_url(
    domain: domain,
    project_id: ENV['WORKOS_PROJECT_ID'],
    redirect_uri: ENV['WORKOS_REDIRECT_URI'],
  )
  redirect authorization_url
end

get '/sso/callback' do
  profile = WorkOS::SSO.profile(
    code: params['code'],
    project_id: ENV['WORKOS_PROJECT_ID'],
  )

  session[:user] = profile.to_json

  redirect '/sso'
end

get '/logout' do
  session[:user] = nil

  redirect '/sso'
end



