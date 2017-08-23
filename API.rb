require 'sinatra/base'
require './Auth'
require './Events'
require './Admin'
require 'json'
require 'sidekiq'
require 'sidekiq-scheduler'


# This class contains all of the web server logic for processing incoming requests from Slack.
class API < Sinatra::Base
  # This is the endpoint Slack will post Event data to.
  post '/events' do

    
    request_data = JSON.parse(request.body.read)
    
    #If not verified, respond to slack verification. If verified, populate maps.
    if(request_data['type'] == 'url_verification') 
      return request_data['challenge']
    else
      request_map = Admin.get_event_map(request_data)
      update_map = Admin.get_update_map()
      user_map = Admin.get_user_map(request_map['channel'])
    end

    user = user_map[request_map['user']] 
    puts request_data

    #Logic to respond to messgaes based upon user text
    if (request_map['type'] == 'message') && (user != 'growth-bot') && (request_map['text'].include? ENV['bot_channel_id']) 

       if (request_map['text'].include? "hello") || (request_map['text'].include? "hi") || (request_map['text'].include? "howdy") || (request_map['text'].include? "hey")
               status 200
               msg = "Hey there, " + user + "!"
               Events.respond(msg,request_map['channel'])
               return {:status => 200}.to_json 

       elsif (request_map['text'].include? "week")
            growth_response = Events.get_growth_response("week", "last_week")
            msg = "Here's your update for the week, " + user + "!\n\n You have completed " + (update_map['week']).to_s + " forms this week. Last week mRelief completed " + (update_map["last_week"]).to_s + " forms. "  + growth_response    
            Events.respond(msg,request_map['channel']) 
            return {:status => 200}.to_json 

        elsif (request_map['text'].include? "month")
            growth_response = Events.get_growth_response("month", "last_month")
            msg = "Here's your update for this month, " + user + "!\n\n You completed " + (update_map['month']).to_s + " forms this month. Last month mRelief completed " + (update_map["last_month"]).to_s + " forms. "  + growth_response    
            Events.respond(msg,request_map['channel']) 
            return {:status => 200}.to_json 
        
          elsif (request_map['text'].include? "quarter")
            growth_response = Events.get_growth_response("quarter", "last_quarter")
            msg = "Here's your update for this quarter, " + user + "!\n\n You have completed " + (update_map['quarter']).to_s + " forms this quarter. Last quarter you had " + (update_map["last_quarter"]).to_s + " forms completed. "  +  growth_response + " So far, mRelief has grown " + (update_map["quarter_percent"]).to_s + "% this quarter."
            Events.respond(msg,request_map['channel']) 
            return {:status => 200}.to_json 

          elsif ( (request_map['text'].include? "year") || (request_map['text'].include? "annual") )
            growth_response = Events.get_growth_response("annual", "last_year")
            msg = "Here's your update for this year, " + user + "!\n\n You have completed " + (update_map['annual']).to_s + " forms this year.  At this time last year, mRelief had " + (update_map["last_year"]).to_s + " forms completed. "  + growth_response + " So far, mRelief has grown " + (update_map["annual_percent"]).to_s + "% this year."
            Events.respond(msg,request_map['channel'])
            return {:status => 200}.to_json 

          elsif(request_map['text'].include? "update")
             msg = "Here's your update, " + user + "!\n\n You have had " + (update_map['quarter']).to_s  +  " forms completed this quarter, " + (update_map['month']).to_s + " forms completed this month, and " + (update_map['week']).to_s + " forms completed this week. You have grown " +  (update_map['quarter_percent']).to_s + "% this quarter, and " + (update_map['annual_percent']).to_s + "% so far this year!" 
             Events.respond(msg,request_map['channel']) 
             return {:status => 200}.to_json 

          elsif(request_map['text'].include? "help")
            file =  File.open("help.txt", "r") 
            msg  = file.read   
            Events.respond(msg,request_map['channel'])  
            return {:status => 200}.to_json           
          
          end

        else 
        puts "Unexpected event:\n"   

  end 

    return {:status => 200}.to_json 

  end
end



