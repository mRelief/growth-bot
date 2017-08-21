require './Auth'
require './API'

# Initialize the app and create the API (bot) and Auth objects.
run Rack::Cascade.new [Auth, API]


