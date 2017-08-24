require './Auth'

# This class populates map with user and API request information to be used during API request handling. 
class Admin
  
    # Returns map of all users associated with their userID
    def self.get_user_map(channel)
     member_map = Hash.new
     uri = URI('https://slack.com/api/users.list')
     res = Net::HTTP.post_form(uri, 'token' => ENV['slack_api_token'], "scope" => "users:read")
     post_data = JSON.parse(res.body)
     post_data['members'].each do |member|
        member_map[member['id']] = member['profile']['first_name']
     end
    return member_map
  end 


  # Returns map of time-periods associated with the amount of forms submitted
  def self.get_update_map(uri)
     growth_metrics = Hash.new
     res = Net::HTTP.get_response(uri)
     response = JSON.parse(res.body)
     post_data = response["data"]
     post_data.each do |time| 
        stringy =  time.first
        growth_metrics[stringy["time-period"]] = stringy["value"]
     end
        puts "GROWTH METRICS"
        puts growth_metrics
        return growth_metrics
  end 

  # Returns map of event details associated with the value specified in the API response
  def self.get_event_map(request_data)
    event_data = Hash.new
    temp = request_data['event']
    event_data['type'] = temp['type']
    event_data['user'] = temp['user']
    event_data['text'] = temp['text']
    event_data['channel'] = temp['channel']
    return event_data
  end

      

end