# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'dotenv/load'
require 'rack/ssl-enforcer'
require 'securerandom'
require 'faker'
require 'jwt'
require 'workos'

FIVE_MINUTES_IN_SECONDS = 5 * 60

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

  organizations = WorkOS::Organizations.list_organizations(
    domains: [domain],
  )

  @organization = organizations&.data&.first ||
    WorkOS::Organizations.create_organization(
      domains: [domain],
      name: domain.partition('.').first,
    )

  @theme = {
    org: params['org'] || 'Cloud App',
    sidebar_color: params['sidebar_color'] || 'fff',
    bg_color: params['bg_color'] || 'fff'
  }

  erb :index, :layout => :layout
end

post '/portal' do
  if params[:intent] == "audit_logs"
    Thread.new {
      ["user.signed_in", "user.signed_out"].each do |action|
        WorkOS::AuditLogs.create_event(
          organization: params[:organization],
          event: {
            action: action,
            occurred_at: Time.now.iso8601(3),
            actor: {
              id: "user_01GBNJC3MX9ZZJW1FSTF4C5938",
              name: Faker::Name.name,
              type: "user"
            },
            targets: [
              {
                id: "team_01GBNJD4MKHVKJGEWK42JNMBGS",
                type: "team"
              }
            ],
            context: {
              location: request.ip,
              user_agent: request.user_agent
            }
          }
        )
      end
     }
  end

  payload = {
    key: ENV['WORKOS_KEY_ID'],
    intent: params[:intent],
    organization: params[:organization],
    scenario: params[:scenario],
    exp: Time.now.to_i + FIVE_MINUTES_IN_SECONDS,
    started_at: (Time.now.to_f * 1000).to_i
  }

  token = JWT.encode payload, WorkOS.key, 'HS256'

  redirect "https://#{ENV['WORKOS_ADMIN_PORTAL_HOSTNAME']}/?token=#{token}"
end
