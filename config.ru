require './app'
config.logger = Logger.new(STDOUT)
run Sinatra::Application