# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'workos'
require 'rack/ssl-enforcer'
require 'securerandom'
require 'faker'

use Rack::SslEnforcer if production?
set :session_secret, ENV['SESSION_SECRET'] || SecureRandom.hex(32)

WorkOS.key = ENV['WORKOS_KEY']

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

  @theme = {
    org: params['org'] || 'Cloud App',
    sidebar_color: params['sidebar_color'] || 'fff',
    bg_color: params['bg_color'] || 'fff'
  }

  puts @theme

  puts @current_user
  erb :index, :layout => :layout
end

post '/portal' do
  organization_name = "portal-demo-#{SecureRandom.uuid}"

  organization = WorkOS::Portal.create_organization(
    domains: ["#{organization_name}.com"],
    name: organization_name,
  )

  portal_link = WorkOS::Portal.generate_link(
    intent: 'sso',
    organization: organization.id
  )

  redirect portal_link
end
