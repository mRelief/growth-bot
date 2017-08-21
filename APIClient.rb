require 'net/http'
require 'rubygems'
require 'json'
require 'sinatra/base'
require 'slack-ruby-client'

class APIClient 

  def initialize(token)
    $token = token
  end 

  def check
    send_message "ping"
  end
   
  def send_message(msg, channel) 
    puts "made it to the client"
    uri = URI('https://slack.com/api/chat.postMessage')
    res = Net::HTTP.post_form(uri, 'token' => $token, 'channel' => channel , 'text' => msg, 'as_user' => 'false', 'username' => 'growth-bot')
    puts res
  end

  def populate_user_map()
    
     member_map = Hash.new
     uri = URI('https://slack.com/api/users.list')
     res = Net::HTTP.post_form(uri, 'token' => $token)
     post_data = JSON.parse(res.body)
     post_data['members'].each do |member|
        member_map[member['id']] = member['profilec']['first_name']
     end
    return member_map
  end 

end
