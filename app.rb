require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative "./models/questions.rb"
require_relative "./models/selection_items.rb"
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
  def h(text)
    Rack::Utils.escape_html(text)
  end

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

get '/browse' do
  require_personality
  require_job
  @job_categories = SelectionItems::JOB_CATEGORIES.sort_by {|k, v| k[:category]}
  @current_user = User.find(session[:user][:id])  
  @users = User.all

  @salaries = SelectionItems::JOB_SALARY

  @search_filter = session[:user][:filter]
  return erb :browse
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
  @job_categories = SelectionItems::JOB_CATEGORIES.sort_by {|k, v| k[:category]}
	return erb :signup
end

post "/signin" do
  password = params[:password]

  user = User.find_by(email: params[:email])
  user_exists = (user != nil)
  
  if user_exists && user.authenticate(params[:password])
    username = user.username
    session[:user] = {id: user.id, email: params[:email], username: username}
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
  image_url = params[:image_url]

  user = User.new(username: params[:username], email: params[:email], password: params[:password], zipcode: params[:zipcode], image_url: image_url)

  if user.save
    job = Job.new(job_title: params[:job_title], category: params[:job_category], satisfaction: params[:job_satisfaction], salary: params[:job_salary], years_experience: params[:job_experience], user_id: user.id)
    if job.save
      session[:user] = {id: user.id, email: params[:email], username: params[:username] }
      redirect "/#{user.username}/profile"
    else
      @errors = user.errors.full_messages
      puts @errors
    end
  else
  	@errors = user.errors.full_messages
  	puts @errors
  end

  redirect '/'
end

get "/profile/edit" do
  require_login
  require_personality

  @user = User.find(session[:user][:id])
  @job_categories = SelectionItems::JOB_CATEGORIES.sort_by {|k, v| k[:category]}
  @salaries = SelectionItems::JOB_SALARY

  return erb :edit_profile
end

post "/user/update" do
  user = User.find(session[:user][:id])

  user.update(image_url: params[:url], email: params[:email], zipcode: params[:zipcode])
  user.job.update(job_title: params[:job_title], satisfaction: params[:job_satisfaction], category: params[:job_category], salary: params[:job_salary])

  redirect "/#{user.username}/profile"
end

get "/:username/profile" do
  # users can view each others' profiles but need to be logged in
  require_login
  require_personality

  @own_profile = (session[:user][:username] == params[:username])

  @user = User.find_by(username: params[:username])

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

  redirect "/#{user.username}/profile"

end
