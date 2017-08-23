require 'sidekiq-scheduler'
require 'net/http'
require '~/playground/API.rb'

uri = URI.parse(ENV['redirect_url'])
channel = ENV['update_channel']
map = Admin.get_update_json()

# This class is associated with an annual cron job and will give an update on forms submitted over the year. 
class YearBotWorker
	include Sidekiq::Worker

	def perform
		msg = "Here's your update for this year, mRelief! You have completed " + (map['annual']).to_s + " forms this year.  At this time last year, mRelief had " + (map["last_year"]).to_s + " forms completed. mRelief has grown " + (map["annual_percent"]).to_s + "% this year."
        	Events.respond(msg, channel, nil, nil)
	end

end

# This class is associated with a quarterly cron job and will give an update on forms submitted over the first quarter. 
class Q1BotWorker
	include Sidekiq::Worker

	def perform
		msg = "Here's your update for this quarter, mRelief! You have completed " + (map['quarter']).to_s + " forms during the first quarter. Last quarter you had " + (map["last_quarter"]).to_s + " forms completed. So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
        Events.respond(msg, channel, nil, nil) 
	end

end

# This class is associated with a quarterly cron job and will give an update on forms submitted over the second quarter. 
class Q2BotWorker
	include Sidekiq::Worker

	def perform
	  msg = "Here's your update for this quarter, mRelief! You have completed " + (map['quarter']).to_s + " forms during the second quarter. Last quarter you had " + (map["last_quarter"]).to_s + " forms completed. So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
      Events.respond(msg, channel, nil, nil) 
	end

end

# This class is associated with a quarterly cron job and will give an update on forms submitted over the third quarter. 
class Q3BotWorker
	include Sidekiq::Worker

	def perform
	  msg = "Here's your update for this quarter, mRelief! You have completed " + (map['quarter']).to_s + " forms during the third quarter. Last quarter you had " + (map["last_quarter"]).to_s + " forms completed. So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
      Events.respond(msg, channel, nil, nil) 
	end

end

# This class is associated with a quarterly cron job and will give an update on forms submitted over the fourth quarter. 
class Q4BotWorker
	include Sidekiq::Worker

	def perform
      msg = "Here's your update for this quarter, mRelief! You have completed " + (map['quarter']).to_s + " forms  during the fourth quarter. Last quarter you had " + (map["last_quarter"]).to_s + " forms completed. So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
      Events.respond(msg, channel, nil, nil) 
	end	

end

# This class is associated with a cron job that runs at the end of 30-day months and will give an update on forms submitted over the given month. 
class Month30BotWorker
	include Sidekiq::Worker

	def perform
      msg = "Here's your update for this quarter, mRelief! You have completed " + (map['month']).to_s + " forms over the past 30 days. Last month you had " + (map["last_month"]).to_s + " forms completed. So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
      Events.respond(msg, channel, nil, nil) 
	end	

end

# This class is associated with a cron job that runs at the end of 31-day months and will give an update on forms submitted over the given month. 
class Month31BotWorker
	include Sidekiq::Worker

	def perform
      msg = "Here's your update for this quarter, mRelief! You have completed " + (map['month']).to_s + " over the last 31 days. Last month you had " + (map["last_month"]).to_s + " forms completed. So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
      Events.respond(msg, channel, nil, nil) 
	end	

end

# This class is associated with a cron job that runs at the end of 28-day months and will give an update on forms submitted over the given month. 
class Month28BotWorker
	include Sidekiq::Worker

	def perform
      msg = "Here's your update for this quarter, mRelief! You have completed " + (map['month']).to_s + " over the last 28 days. Last month you had " + (map["last_month"]).to_s + " forms completed. So far, mRelief has grown " + (map["quarter_percent"]).to_s + "% this quarter."
      Events.respond(msg, channel, nil, nil) 
	end	

end

# This class is associated with a cron job that runs weekly and will give an update on forms submitted over the week. 
class WeekWorker
	include Sidekiq::Worker

	def perform
		msg = "Here's your update for the week, mRelief ! You have completed" + (map['week']).to_s + " forms this week. Last week you had " + (map["last_week"]).to_s + " forms completed. Let's keep growing!"  
        Events.respond(msg, channel, nil, nil) 
	end

end