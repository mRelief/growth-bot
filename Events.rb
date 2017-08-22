require './Auth'
require './Admin'

class Events
  $token = ENV['slack_api_token']
  $map = Admin.get_update_map()

  def self.respond(msg, channel)
    uri = URI.parse('https://slack.com/api/chat.postMessage')
    res = Net::HTTP.post_form(uri, 'token' => $token, 'channel' => channel , 'text' => msg, 'as_user' => 'false', 'username' => 'growth-bot')
  end

 def self.get_growth_response(this_time_period, last_time_period)
    gr =  "Keep up the good work. Our growth is looking good!" 
    if (($map[last_time_period] > $map[this_time_period]) || ($map[this_time_period] == $map[last_time_period])) 
        gr = "Let's try to see some more growth this week!"
    end
    return gr
  end

end
