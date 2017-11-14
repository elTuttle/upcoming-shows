require './config/environment'
require 'sinatra/base'
require 'sinatra/flash'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :session_secret, "secret"
    enable :sessions
    register Sinatra::Flash
  end

  get '/' do
    @session = session
    erb :index
  end

  get '/signup' do
    @session = session
    erb :'users/create_user'
  end

  get '/logout' do
    session.clear
    redirect '/login'
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

  get '/events/new' do
    @session = session
    erb :'events/create_event'
  end

  get '/flashmessage' do
    flash[:message] = "Logged Out"
    redirect to '/'
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    @session = session
    erb :'users/show'
  end

  get '/events/:id' do
    @event = Event.find_by(id: params[:id])
    @session = session
    erb :'events/show_event'
  end

  delete '/events/:id/delete' do
    if session[:user_id] != nil
      event = Event.find_by(id: params[:id])
      user = User.find_by(id: session[:user_id])
      if user.id == event.user.id
        event.destroy
        redirect to "/events"
      else
        flash[:message] = "Can't delete someone else's Event!"
        redirect to "/events/#{event.id}"
      end
    else
      redirect to '/login'
    end
  end

  get '/events/:id/edit' do
    if session[:user_id] != nil
      @event = Event.find_by(id: params[:id])
      @user = User.find_by(id: session[:user_id])
      @session = session
      if @user.id == @event.user.id
        erb :'events/edit_event'
      else
        flash[:message] = "Can't edit someone else's Event!"
        redirect to "/events/#{event.id}"
      end
    else
      redirect to '/login'
    end
  end

  get '/events/:city/:state' do
    @events = []

    city = params[:city].split("-")
    city.each do |c|
      if c == "-"
        c = ""
      end
      c.capitalize!
    end
    @city = city.join(" ")

    state = params[:state].split("-")
    state.each do |s|
      if s == "-"
        s = ""
      end
      s.capitalize!
    end
    @state = state.join(" ")

    @session = session
    Event.all.each do |event|
      if event.city == @city && event.state == @state
        @events << event
      end
    end
    erb :'/events/local_events'
  end

  post '/signup' do
    if params[:username] == ""||params[:email] == ""||params[:password] == ""
      flash[:message] = "Can't leave any fields blank"
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
        flash[:message] = "Could not find account, one or more fields incorrect"
        redirect to '/login'
      end
    end
  end

  post '/events' do
    if params[:name] == ""||params[:city] == ""||params[:state] == ""||params[:description] == ""||params[:date] == ""||params[:time] == ""
      flash[:message] = "Can't leave any fields blank"
      redirect to '/events/new'
    else
      user = User.find_by(id: session[:user_id])
      event = Event.create(params)
      event.update(user: user)
      redirect to '/events'
    end
  end

  post '/events/search' do
    city = params[:city]
    city = city.split.join("-").downcase
    state = params[:state]
    state = state.split.join("-").downcase
    redirect to "/events/#{city}/#{state}"
  end

  patch '/events/:id' do
    event = Event.find_by(id: params[:id])
    if params[:name] == ""||params[:city] == ""||params[:state] == ""||params[:description] == ""||params[:date] == ""||params[:time] == ""
      flash[:message] = "Can't leave any fields blank"
      redirect to "/events/#{event.id}/edit"
    else
      event.update(name: params[:name], city: params[:city], state: params[:state], description: params[:description],date: params[:date],time: params[:time])
      redirect to "/events/#{event.id}"
    end
  end

end
