# frozen_string_literal: true

require 'sinatra'
require "sinatra/reloader" if development?
require 'workos'
require 'securerandom'
require 'faker'



get '/' do
  company_name = Faker::Internet.domain_word
  domain = Faker::Internet.domain_name(domain: company_name)
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
  result = WorkOS::SSO.promote_draft_connection(
    token: params['token'],
  )

  puts result

  result
end