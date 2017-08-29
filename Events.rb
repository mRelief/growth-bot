require './Auth'
require './Admin'

# This class contains all of the event logic for API requests to the Slack API. 
class Events
  $token = ENV['slack_api_token']

  #Responds to user messages with a post request to the Slack API chat.postMessage method.
  def self.respond(msg, channel)
    uri = URI.parse('https://slack.com/api/chat.postMessage')
    res = Net::HTTP.post_form(uri, 'token' => $token, 'channel' => channel , 'text' => msg, 'as_user' => 'false', 'username' => 'growth-bot')

  end

#Returns appopriate motivational message based upon growth numbers.
 def self.get_growth_response(map, this_time_period, last_time_period)
    gr =  "Keep up the good work. Our growth is looking good!" 
    if ((map[last_time_period] > map[this_time_period]) || (map[this_time_period] == map[last_time_period])) 
        gr = "Let's try to see some more growth!"
    end
    return gr
  end

#Returns appopriate percent response based upon growth percentages.
  def self.get_percent_response(metric)
    if (metric != nil) { 
        percent_response = metric.to_s +  "% regarding applications submitted."
    } else {
        percent_response = "over 100% regarding applications becuase we did not have any applications submitted last year!"
    }
    return percent_response
  end


end
