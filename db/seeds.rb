require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative "./models/questions.rb"
require_relative "./models/job_categories.rb"
require_relative "config/environments.rb"

require_relative "./models/job"
require_relative "./models/personality"
require_relative "./models/user"

