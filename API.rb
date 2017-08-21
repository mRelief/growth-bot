require 'sinatra/base'
require 'slack-ruby-client'
require './APIClient'
require './Auth'
require 'json'
require 'sidekiq'
require 'sidekiq-scheduler'


# This class contains all of the web server logic for processing incoming requests from Slack.
class API < Sinatra::Base
  # This is the endpoint Slack will post Event data to.
  post '/events' do
   #Extract the Event payload from the request and parse the JSON
 
    $request_data = JSON.parse(request.body.read)
    puts $request_data
    if($request_data['type'] == 'url_verification') 
      return $request_data['challenge']
    else
      $event_data = $request_data['event']
      type = $event_data['type']
      userID = $event_data['user']
      text = $event_data['text']
      channel = $event_data['channel']
      user_map = Admin.populate_user_map(channel)
      username = user_map[userID]
      map = Admin.get_update_json()
    end

     puts "CHANNEL: " + channel + "\n\n" 

    if (type == 'message') && (username != 'growth-bot') && (text.include? ENV[bot_channel_id]) 
       if (text.include? "hello") || (text.include? "hi") || (text.include? "howdy") || (text.include? "hey")
               msg = "Hey there " + user_map[userID] + "!"
               Events.respond(msg, channel, nil, user_map[userID])
       elsif (text.include? "week")
            growth_response = "Keep up the good work. Our growth is looking good!" 
            if ((map["last_week"] > map["week"]) || (map["last_week"] == map["week"])) 
               growth_response = "Let's try to see some more growth this week!"
            end
            msg = "Here's your update for the week, " + username + "! You have had " + (map['week']).to_s + " forms completed this week. Last week you had " + (map["last_week"]).to_s + " forms completed. "  + growth_response    
            Events.respond(msg, channel, nil, user_map[userID]) 
        elsif (text.include? "month")
            growth_response = "Keep up the good work. Our growth is looking good!" 
            if ((map["last_month"] > map["month"]) || (map["last_month"] == map["month"])) 
               growth_response = "Let's try to see some more growth this month"
            end
            msg = "Here's your update for this month, " + username + "! You have had " + (map['month']).to_s + " forms completed this month. Last month you had " + (map["last_month"]).to_s + " forms completed. "  + growth_response    
            Events.respond(msg, channel, nil, user_map[userID]) 
          elsif (text.include? "quarter")
            gr = "Keep up the good work. Our growth is looking good!" 
            if ((map["last_quarter"] > map["quarter"]) || (map["last_quarter"] == map["quarter"])) 
               gr = "Let's try to see some more growth this quarter!"
            end
            msg = "Here's your update for this quarter, " + username + "! You have had " + (map['quarter']).to_s + " forms completed this quarter. Last quarter you had " + (map["last_quarter"]).to_s + " forms completed. "  + gr + "So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
            Events.respond(msg, channel, nil, user_map[userID]) 
          elsif (text.include? "year")
            gr = "Keep up the good work. Our growth is looking good!" 
            if ((map["last_year"] > map["annual"]) || (map["last_year"] == map["annual"])) 
               gr = "Let's try to see some more growth this year!"
            end
            msg = "Here's your update for this year, " + username + "! You have had " + (map['annual']).to_s + " forms completed this year.  At this time last year, mRelief had " + (map["last_year"]).to_s + " forms completed. "  + gr + "So far, mRelief has grown " + (map["annual_percent"]).to_s + "% this year."
            Events.respond(msg, channel, nil, user_map[userID])
          elsif(text.include? "update")
             puts map
             msg = "Here's your update, " + username + "! You have had " + (map['quarter']).to_s  +  " forms completed this quarter, " + (map['month']).to_s + " forms completed this month, and " + (map['week']).to_s + " forms completed this week. You have grown " +  (map['quarter_percent']).to_s + "% this quarter, and " + (map['annual_percent']).to_s + "% so far this year!" 
             Events.respond(msg, channel, nil, user_map[userID]) 
          elsif(text.include? "help")
            file =  File.open("help.txt", "r") 
            msg  = file.read   
            Events.respond(msg, channel, nil, user_map[userID])            
            end
        else 
        puts "Unexpected event:\n"
        #puts JSON.pretty_generate($request_data)        
  end 
    return {:status => 200}.to_json  
end
end


class Events
  # A new user joins the team
  def self.respond(msg, channel, attachment, user)
    uri = URI.parse('https://slack.com/api/chat.postMessage')
        if (attachment == nil)
           res = Net::HTTP.post_form(uri, 'token' => ENV['slack_api_token'], 'channel' => channel , 'text' => msg, 'as_user' => 'false', 'username' => 'growth-bot')
        else
          res = Net::HTTP.post_form(uri, 'token' =>ENV['slack_api_token'], "text" => msg, 'channel' => channel, 'as_user' => 'false', 'username' => 'growth-bot')
        end
    end
end

class Admin
  

    def self.populate_user_map(channel)
     member_map = Hash.new
     uri = URI('https://slack.com/api/users.list')
     res = Net::HTTP.post_form(uri, 'token' => ENV['slack_api_token'], 'channel' => channel)
     post_data = JSON.parse(res.body)
     post_data['members'].each do |member|
        member_map[member['id']] = member['profile']['first_name']
     end
    return member_map
  end 

  def self.get_update_json()
     $growth_metrics = Hash.new
     uri = URI(ENV['endpoint_url'])
     res = Net::HTTP.get_response(uri)
     res = JSON.parse(res.body)
     post_data = res["data"]
      post_data.each do |time| 
        stringy =  time.first
        $growth_metrics[stringy["time-period"]] = stringy["value"]
     end
       return $growth_metrics
  end 

end