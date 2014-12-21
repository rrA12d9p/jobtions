require 'faker'

require_relative "../models/questions.rb"
require_relative "../models/selection_items.rb"

require_relative "../models/job"
require_relative "../models/personality"
require_relative "../models/user"

def create_admin()
	STDOUT.puts "Admin password:"
	system 'stty -echo'
	password = STDIN.gets.chomp
	system 'stty echo'

	user = User.create(username: "techytrey", email: "techytrey.mail@gmail.com", password: password, zipcode: "22201", image_url: "https://media.licdn.com/mpr/mpr/shrink_200_200/p/7/005/008/243/14d3bf1.jpg", dummy: false)
  job = Job.create(job_title: "Solution Engineer", category: "Business Development", satisfaction: "very_satisfied", salary: "eighty", years_experience: "2", user_id: user.id, dummy: false)
  personality = Personality.create( extraversion: 0, agreeableness: 25, conscientiousness: 50, emotional_stability: 50, intellect_imagination: 75, user_id: user.id, dummy: false)
end

def seed_records(num)
	puts "Seeding DB"

	num.times do |i|
		name = Faker::Name.name
		username = Faker::Internet.user_name(name)
		email = Faker::Internet.free_email(name)
		password = "password"
		zipcode = Faker::Address.zip

		person = ['men', 'women'].sample + '/' + rand(1..90).to_s
		image_url ||= "http://api.randomuser.me/portraits/med/#{person}.jpg"

		job_category = SelectionItems::JOB_CATEGORIES.sample[:category]
		satisfaction = ["very_satisfied", "satisfied", "somewhat_satisfied", "somewhat_dissatisfied", "very_dissatisfied"].sample
		salary = ["hundred", "eighty", "fifty", "thirty", "zero"].sample
		job_experience = rand(0..40).to_s

		user = User.new(username: username, email: email, password: password, zipcode: zipcode, image_url: image_url, dummy: true)

		if user.save
			puts "(#{i+1}/#{num}):	#{user.inspect}"
		  job = Job.new(job_title: Faker::Name.title, category: job_category, satisfaction: satisfaction, salary: salary, years_experience: job_experience, user_id: user.id, dummy: true)
		  p_hash = {extraversion: rand(10000).to_f/100, agreeableness: rand(10000).to_f/100.00, conscientiousness: rand(10000).to_f/100, emotional_stability: rand(10000).to_f/100, intellect_imagination: rand(10000).to_f/100, user_id: user.id, dummy: true}
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

create_admin
seed_records(100)