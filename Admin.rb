require './Auth'

class Admin
  
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

  def self.get_update_map()
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

  def self.get_event_map(request_data)
    event_data = Hash.new
    temp = $request_data['event']
    event_data['type'] = temp['type']
    event_data['user'] = temp['user']
    event_data['text'] = temp['text']
    event_data['channel'] = temp['channel']
    return event_data
  end

      

end