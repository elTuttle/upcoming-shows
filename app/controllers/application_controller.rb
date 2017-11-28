require './config/environment'
require 'sinatra/base'
require 'sinatra/flash'

class ApplicationController < Sinatra::Base

  include Helpers

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :session_secret, "secret"
    enable :sessions
    register Sinatra::Flash
  end

  get '/' do

    if !is_logged_in?
      erb :index
    else
      redirect to '/events'
    end
  end

  get '/signup' do
    if !is_logged_in?
      erb :'users/create_user'
    else
      redirect to '/events'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  get '/login' do
    if !is_logged_in?
      erb :'users/login'
    else
      redirect to '/events'
    end
  end

  get '/events' do
    if is_logged_in?
      @user = User.find_by(id: session[:user_id])
      erb :'events/events'
    else
      redirect to '/login'
    end
  end

  get '/events/new' do
    if is_logged_in?
      erb :'events/create_event'
    else
      redirect to '/login'
    end
  end

  get '/users/:slug' do
    if is_logged_in?
      @user = User.find_by_slug(params[:slug])
      erb :'users/show'
    else
      redirect to '/login'
    end
  end

  get '/events/:id' do
    if is_logged_in?
      @event = Event.find_by(id: params[:id])
      erb :'events/show_event'
    else
      redirect to '/login'
    end
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
      if current_user.id == @event.user.id
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
    if is_logged_in?
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

      Event.all.each do |event|
        if event.city == @city && event.state == @state
          @events << event
        end
      end
      erb :'/events/local_events'
    else
      redirect to '/login'
    end
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

  post '/events/:event_id/comments' do
    if @event = Event.find_by(id: params[:event_id])
      @comment = @event.comments.build(params[:comment])
      @comment.user_id = session[:user_id]
      if @comment.save
        redirect to "/events/#{@event.id}"
      else
        flash[:message] = "Couldn't Save Comment"
        redirect to "/events/#{@event.id}"
      end
    else
      flash[:message] = "Couldn't Find Event"
      redirect to "/events/#{@event.id}"
    end
  end

  delete '/events/:event_id/comments/:id/delete' do
    if @comment = Comment.find_by(id: params[:id])
      @comment.destroy
      flash[:message] = "Comment Deleted"
      redirect to "/events/#{params[:event_id]}"
    else
      flash[:message] = "couldn't find comment"
      redirect to "/events/#{params[:event_id]}"
    end
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
