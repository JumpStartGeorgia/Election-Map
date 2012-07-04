# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'girl_friday/server'

#run ElectionMap::Application

# the following is a girl friday server so processes can be watched
run Rack::URLMap.new \
  "/"       => ElectionMap::Application,
  "/girl_friday" => GirlFriday::Server.new


