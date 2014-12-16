require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative "./models/questions.rb"
require_relative  'config/environments.rb'

require_relative "./models/job"
require_relative "./models/personality"
require_relative "./models/user"

enable :sessions

before do
	session[:user] ||= []
end

get '/' do
	return erb :index
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
  else
  	@errors = user.errors.full_messages
  	puts @errors
  end

  redirect '/'
end

get "/:username/home" do 
  redirect '/' if session[:user] == [] || params[:username] != session[:user][:username]
  user = User.find(session[:user][:id])  
  existing_personality = Personality.find_by(user_id: user.id)

  redirect "/#{params[:username]}/questionnaire" if !existing_personality

  return erb :user_home
end

get "/:username/profile" do 
  @own_profile = session[:user][:username] == params[:username]

  @user = User.find_by(username: params[:username])
  redirect '/' if session[:user] == [] || @user == nil # users can view each others' profiles
  
  @existing_personality = Personality.find_by(user_id: @user.id)

  redirect "/#{params[:username]}/questionnaire" if !@existing_personality

  return erb :user_profile
end

post "/save-questionnaire" do
  user = User.find(session[:user][:id])

  return "error" if user == nil

  answers = params
  questions = Questions::ALL

  personality = {extraversion: 0, agreeableness: 0, conscientiousness: 0, emotional_stability: 0, intellect_imagination: 0}
  
  extraversion_questions = []

  answers.each_with_index do |arr, i|
    value = arr[1].to_i
    trait = questions[i][:category].to_sym
    change = questions[i][:value].to_i
    personality[trait] += value * change
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
