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
  company_name = params['company'] || "demo-#{Time.now.to_i}"
  domain = company_name + '.com'

  @current_user = {
    email: "user@#{domain}",
    name: 'Demo User',
  }

  @theme = {
    org: params['org'] || 'Cloud App',
    sidebar_color: params['sidebar_color'] || 'fff',
    bg_color: params['bg_color'] || 'fff'
  }

  erb :index, :layout => :layout
end

post '/portal' do
  domain = params[:email].partition('@').last

  organizations = WorkOS::Portal.list_organizations(
   domains: [domain],
  )

  if organizations.data.empty
    organization = WorkOS::Portal.create_organization(
     domains: [domain],
     name: domain.partition('.').first,
    )

    portal_link = WorkOS::Portal.generate_link(
     intent: 'sso',
     organization: organization.id
    )

    redirect portal_link
  else
    organization = organizations.data.first

    portal_link = WorkOS::Portal.generate_link(
     intent: 'sso',
     organization: organization['id']
    )

    redirect portal_link
  end
end
