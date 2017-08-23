require 'net/http'
require 'rubygems'
require 'json'
require 'dotenv'
require 'sinatra/base'
require 'slack-ruby-client'
 
# This class will perfom the authorization flow of installing a Slack app to a team. 
class Auth < Sinatra::Base

  Dotenv.load('.env.development', '.env.production')

  
  BOT_SCOPE = 'identify,bot,channels:history,im:history,users:read,chat:write:bot'

  SLACK_CONFIG = {
  slack_client_id: ENV['slack_client_id'],
  slack_api_secret: ENV['slack_api_secret'],
  slack_verification_token:ENV['slack_verification_token'],
  slack_redirect_uri:ENV['redirect_url']
  }
  
  add_to_slack_button = %(
     <a href=\"https://slack.com/oauth/authorize?scope=#{BOT_SCOPE}&client_id=#{SLACK_CONFIG[:slack_client_id]}&redirect_uri=#{SLACK_CONFIG[:slack_redirect_uri]}\">
       <img alt=\"Add to Slack\" height=\"40\" width=\"139\" src=\"https://platform.slack-edge.com/img/add_to_slack.png\"/>
     </a>
  )

  get '/' do
    redirect '/begin_auth'
  end


  get '/begin_auth' do
     status 200
     body add_to_slack_button
  end

  get '/finish_auth' do
    status 200
    begin
     puts params
      slack_code = params[:code]
      uri = URI.parse("https://slack.com/api/oauth.access")
      response = Net::HTTP.post_form(uri, {"code" => slack_code, "client_id" => SLACK_CONFIG[:slack_client_id], "client_secret" => SLACK_CONFIG[:slack_api_secret]})
    rescue 
       status 403
       body "Auth failed."
    end
  end

  
end
