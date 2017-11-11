require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    @session = session
    erb :index
  end

  get '/signup' do
    @session = session
    erb :'users/create_user'
  end

  get '/login' do
    @session = session
    erb :'users/login'
  end

  get '/events' do
    @user = User.find_by(id: session[:user_id])
    @session = session
    erb :'events/events'
  end

  get '/events' do
    @session = session
    erb :'events/create_event'
  end

  post '/signup' do
    if params[:username] == ""||params[:email] == ""||params[:password] == ""
      redirect to '/signup'
    else
      user = User.create(params)
      session[:user_id] = user.id
      redirect to '/events'
    end
  end

  post '/login' do
    if params[:username] == ""||params[:password] == ""
      redirect to '/login'
    else
      user = User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect to '/events'
      else
        redirect to '/login'
      end
    end
  end

  post '/events' do
    "#{params}"
  end

end
