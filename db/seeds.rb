# require 'sinatra'
# require 'sinatra/reloader'
# require 'sinatra/activerecord'
require 'faker'

require_relative "../models/questions.rb"
require_relative "../models/selection_items.rb"

require_relative "../models/job"
require_relative "../models/personality"
require_relative "../models/user"

def seed_records(num)
	num.times do
		name = Faker::Name.name
		username = Faker::Internet.user_name(name)
		email = Faker::Internet.free_email(name)
		password = "password"
		zipcode = Faker::Address.zip

		person = ['men', 'women'].sample + '/' + rand(1..90).to_s
		image_url ||= "http://api.randomuser.me/portraits/med/#{person}.jpg"

		job_category = SelectionItems::JOB_CATEGORIES.sample[:category]
		satisfaction = SelectionItems::JOB_SATISFACTION.sample
		salary = SelectionItems::JOB_SALARY.sample
		job_experience = rand(0..40).to_s

		user = User.new(username: username, email: email, password: password, zipcode: zipcode, image_url: image_url)

		if user.save
		  job = Job.new(job_title: Faker::Name.title, category: job_category, satisfaction: satisfaction, salary: salary, years_experience: job_experience, user_id: user.id)
		  p_hash = {extraversion: rand(10000).to_f/100, agreeableness: rand(10000).to_f/100.00, conscientiousness: rand(10000).to_f/100, emotional_stability: rand(10000).to_f/100, intellect_imagination: rand(10000).to_f/100, user_id: user.id}
		  personality = Personality.new(p_hash)
		  if job.save && personality.save
		  else
		    @errors = user.errors.full_messages
		    puts @errors
		  end
		else
			@errors = user.errors.full_messages
			puts @errors
		end
	end
end

seed_records(100)