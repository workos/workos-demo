# frozen_string_literal: true

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
  WorkOS::SSO.create_connection(
    source: params['token'],
  )
end