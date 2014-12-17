require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative "./models/questions.rb"
require_relative "./models/job_categories.rb"
require_relative "config/environments.rb"

require_relative "./models/job"
require_relative "./models/personality"
require_relative "./models/user"

enable :sessions

before do
	session[:user] ||= []
  # clear the session if the user no longer exists in the db
  if !session[:user].empty? && session[:user].has_key?(:id)
    user_id = session[:user][:id]
    if !User.exists?(user_id)
      session.clear
      session[:user] ||= []
    else
      @current_user = User.find(user_id)
      @logged_in = session[:user] != []
    end
  else
    @current_user = nil
  end
end

helpers do
  def require_login
    redirect "/" if !@logged_in
  end

  def require_personality
    require_login
    user_id = session[:user][:id]
    user = User.find(user_id)
    existing_personality = Personality.find_by(user_id: user_id)
    redirect "/#{user.username}/questionnaire" if !existing_personality
  end

  def require_job
    require_login
    user_id = session[:user][:id]
    user = User.find(user_id)
    existing_job = Job.find_by(user_id: user_id)
    redirect "/#{user.username}/profile" if !existing_job
  end
end

get '/' do
  return erb :index
end

get '/mixituptest' do
  return erb :mixituptest
end

get '/search' do
  require_personality
  require_job
  @job_categories = JobCategories::ALL.sort_by {|k, v| k[:category]}
  @current_user = User.find(session[:user][:id])  
  @users = User.all
  return erb :search
end

get '/:username/questionnaire' do
  @questions = Questions::ALL.shuffle
  @questions.map! {|h| h[:question]}
  redirect '/' if session[:user] == [] || params[:username] != session[:user][:username]
  return erb :questionnaire
end

get '/signin' do
	return erb :signin
end

get '/signup' do
  @job_categories = JobCategories::ALL.sort_by {|k, v| k[:category]}
	return erb :signup
end

post "/signin" do
  email = params[:email]
  password = params[:password]

  user = User.find_by(email: email)
  user_exists = (user != nil)
  
  if user_exists && user.authenticate(password)
    username = user.username
    session[:user] = {id: user.id, email: email, username: username}
    redirect "/"
  else
    redirect "/signin"
  end
end

get "/signout" do
  session.clear
  redirect '/signin'
end

post "/signup" do
  username = params[:username]
  email = params[:email]
  password = params[:password]
  zipcode = params[:zipcode]

  user = User.new(username: username, email: email, password: password, zipcode: zipcode)

  if user.save
  	session[:user] = {id: user.id, email: email, username: username }
    
    job = Job.new(job_title: params[:job_title], category: params[:job_category], satisfaction: params[:job_satisfaction], salary: params[:job_salary], years_experience: params[:job_experience], user_id: user.id)
    if job.save
      puts "*Saved the job!"
    else
      puts "*couldn't save job"
      p job
      @errors = user.errors.full_messages
      puts @errors
    end
  else
    puts "*couldn't save user"
  	@errors = user.errors.full_messages
  	puts @errors
  end

  redirect '/'
end

# post "/:username/profile/update" do
#   @own_profile = session[:user][:username] == params[:username]


#   if @own_profile
#     existing_job = Job.find_by(user_id: user.id)

#     params = {job_title: job_title, years_experience: years_experience, category: category, salary: salary, user_id: user.id}

#     if existing_job
#       user.job.update(params)
#     else
#       job = Job.create(params)
#     end
#   end
# end

get "/:username/profile" do 
  require_login
  require_personality

  @own_profile = session[:user][:username] == params[:username]

  @user = User.find_by(username: params[:username])

  # users can view each others' profiles but need to be logged in
  redirect '/' if session[:user] == [] || @user == nil 

  return erb :user_profile
end

post "/save-questionnaire" do
  require_login
  user = User.find(session[:user][:id])

  return "error" if user == nil

  answers = params
  questions = Questions::ALL

  personality = {extraversion: 0, agreeableness: 0, conscientiousness: 0, emotional_stability: 0, intellect_imagination: 0}
  
  answers.each_with_index do |arr, i|
    value = arr[1].to_i
    trait = questions[i][:category].to_sym
    change = questions[i][:value].to_i
    personality[trait] += value * change
  end

  # convert each total to a percentage
  questions_per_trait = 20
  max_score = 4
  max_trait_score = questions_per_trait * max_score

  personality.each do |k,v|
    personality[k] = (v.to_f/max_trait_score.to_f * 100).round(2)
  end

  params = {extraversion: personality[:extraversion], agreeableness: personality[:agreeableness], conscientiousness: personality[:conscientiousness], emotional_stability: personality[:emotional_stability], intellect_imagination: personality[:intellect_imagination], user_id: user.id}

  existing_personality = Personality.find_by(user_id: user.id)

  if existing_personality
    user.personality.update(params)
  else
    personality = Personality.create(params)
  end

  redirect '/'

end
