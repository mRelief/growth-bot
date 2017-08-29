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
      forms_submitted_map = Admin.get_update_map(ENV['endpoint_url'])
      applications_submitted_map = Admin.get_update_map(ENV['app_endpoint_url'])
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
            growth_response = Events.get_growth_response(forms_submitted_map, "week", "last_week")
            msg = "Here's your update for the week, " + user + "!\n\n You have completed " + (forms_submitted_map['week']).to_s + " forms and " + (applications_submitted_map['week']).to_s + " applications this week. Last week mRelief completed " + (forms_submitted_map["last_week"]).to_s + " forms and " + (applications_submitted_map['last_week']).to_s + " applications. \n\n"  + growth_response 

            Events.respond(msg,request_map['channel']) 
            return {:status => 200}.to_json 

        elsif (request_map['text'].include? "month")
            growth_response = Events.get_growth_response(forms_submitted_map, "month", "last_month")
            msg = "Here's your update for this month, " + user + "!\n\n You completed " + (forms_submitted_map['month']).to_s + " forms and " + (applications_submitted_map['month']).to_s + " applications this month. Last month mRelief completed " + (forms_submitted_map["last_month"]).to_s + " forms and " + (applications_submitted_map['last_month']).to_s + " applications. \n\n"  + growth_response    
            Events.respond(msg,request_map['channel']) 
            return {:status => 200}.to_json 
        
          elsif (request_map['text'].include? "quarter")
            growth_response = Events.get_growth_response(forms_submitted_map, "quarter", "last_quarter")
            msg = "Here's your update for this quarter, " + user + "!\n\n You have completed " + (forms_submitted_map['quarter']).to_s + " forms and " + (applications_submitted_map['quarter']).to_s + " applications this quarter. Last quarter you had " + (forms_submitted_map["last_quarter"]).to_s + " forms and " + (applications_submitted_map['last_quarter']).to_s + " applications completed. "  +  growth_response + "\n\nSo far, mRelief has grown " + (forms_submitted_map["quarter_percent"]).to_s + "% compared to last quarter regarding forms submitted and " + Events.get_percent_response(applications_submitted_map['quarter_percent'])
            Events.respond(msg,request_map['channel']) 
            return {:status => 200}.to_json 

          elsif ( (request_map['text'].include? "year") || (request_map['text'].include? "annual") )
            growth_response = Events.get_growth_response(forms_submitted_map, "annual", "last_year")
            msg = "Here's your update for this year, " + user + "!\n\n You have completed " + (forms_submitted_map['annual']).to_s + " forms and " + (applications_submitted_map['annual']).to_s + " applications this year.  At this time last year, mRelief had " + (forms_submitted_map["last_year"]).to_s + " forms and " + (applications_submitted_map['last_year']).to_s + " applications completed. "  + growth_response + "\n\nSo far, mRelief has grown " + (forms_submitted_map["annual_percent"]).to_s + "% compared to last year regarding forms submitted and " + Events.get_percent_response(applications_submitted_map['annual_percent'])
            Events.respond(msg,request_map['channel'])
            return {:status => 200}.to_json 

          elsif(request_map['text'].include? "update")
             msg = "Here's your update, " + user + "!\n\n You have had " + (forms_submitted_map['quarter']).to_s  +  " forms and " + (applications_submitted_map['quarter']).to_s + " applications completed this quarter, " + (forms_submitted_map['month']).to_s + " forms and " + (applications_submitted_map['month']).to_s + " applications completed this month, and " + (forms_submitted_map['week']).to_s + " forms and " + (applications_submitted_map['week']).to_s + " applications completed this week.\n\n You have grown " +  (forms_submitted_map['quarter_percent']).to_s + "% compared to last quarter regarding forms submitted and " + Events.get_percent_response(applications_submitted_map['annual_percent'] )+ "So far this year, mRelief has grown " +  (forms_submitted_map['annual_percent']).to_s + "%  in terms of forms submitted regarding forms submitted and " + Admin.get_percent_response(applications_submitted_map['quarter_percent'])  
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



