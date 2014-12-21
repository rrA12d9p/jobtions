require './app'
run Sinatra::Application
config.logger = Logger.new(STDOUT)