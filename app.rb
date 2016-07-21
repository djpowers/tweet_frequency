require 'sinatra'
require 'sinatra/reloader'
require 'omniauth-twitter'
require 'twitter'
require 'chartkick'

enable :sessions
use OmniAuth::Builder do
  provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
end

helpers do
  def admin?
    session[:admin]
  end
end

configure :development, :test do
  require 'pry'
  require 'dotenv'
  Dotenv.load
end

configure do
  set :views, 'app/views'
end

Dir[File.join(File.dirname(__FILE__), 'app', '**', '*.rb')].each do |file|
  require file
  also_reload file
end

get '/' do
  @title = "You Tweet Too Much"
  erb :index
end

get '/login' do
  redirect to("/auth/twitter")
end

get '/auth/twitter/callback' do
  env['omniauth.auth'] ? session[:admin] = true : halt(401,'Not Authorized')
  session[:credentials] = env['omniauth.auth']['credentials']
  redirect to("/twitter_stats")
end

get '/auth/failure' do
  params[:message]
end

get '/twitter_stats' do
  halt(401,'Not Authorized') unless admin?
  "This is the private page - members only"

  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['CONSUMER_KEY']
    config.consumer_secret     = ENV['CONSUMER_SECRET']
    config.access_token        = session[:credentials][:token]
    config.access_token_secret = session[:credentials][:secret]
  end

  timeline_tweets = client.home_timeline(count:200)
  counts = Hash.new(0)
  timeline_tweets.each do |tweet|
    counts[tweet.user.name] += 1
  end
  @sorted_counts = counts.sort_by(&:last).reverse
  erb :twitter_stats
end
