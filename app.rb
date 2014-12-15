require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

require_relative  'config/environments.rb'

require_relative "./models/user"
require_relative "./models/gift"

enable :sessions

before do
	session[:user] ||= []
	path_no_base = request.url.gsub(request.base_url, '')
  if session[:user].empty? && path_no_base != "/login" && path_no_base != "/signup"
    redirect "/login"
  end
end

get '/' do
	return erb :index
end

get '/profile' do
	return erb :profile
end

get '/gifts' do 
	@gifts = Gift.all
	return erb :gifts
end

get '/login' do
	return erb :login
end

get '/signup' do
	return erb :signup
end

post "/login" do
  email = params[:email]
  password = params[:password]

  user = User.find_by(email: email)
  user_exists = (user != nil)
  
  if user_exists && user.authenticate(password)
    session[:user] = {id: user.id, email: email}
    redirect "/"
  end
  
  redirect "/login"
end

get "/logout" do
  session.clear
  redirect '/'
end

post "/signup" do
  email = params[:email]
  password = params[:password]
  gift_title = params[:gift_title]
  gift_desc = params[:gift_desc]

  user = User.new(email: email, password: password)

  if user.save
  	session[:user] = {id: user.id, email: email}
  	gift = user.gift.new(title: gift_title, desc: gift_desc)
 		redirect "/"
  else
  	@errors = user.errors.full_messages
  	puts @errors
  end

  redirect '/'
end
