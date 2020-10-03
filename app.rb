require 'sinatra'
require 'sinatra/activerecord'
require 'rack/attack'
require 'redis-store'
require_relative 'models/feedback'
require_relative 'config'

config = Config.new

set :environment, config.enviroment
set :login, config.get('LOGIN', 'oleg')
set :password, config.get('PASSWORD', '1234')
set :api_token, config.get('API_TOKEN', '1234')
set :cache_store, Redis::Store.new(url: config.get('REDIS_URL', 'redis://localhost:6379'))
set :database, { url: config.get('DATABASE_URL', 'postgres://app@localhost/mpz_feedback_development') }

use Rack::Attack
Rack::Attack.cache.store = settings.cache_store
Rack::Attack.throttle('req/ip', limit: 100, period: 30.minutes) do |req|
  req.ip
end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.login, settings.password]
  end
end

get '/' do
  protected!
  erb :index, locals: { items: Feedback.ordered }
end

post '/delete' do
  protected!
  id = params.fetch('id')
  Feedback.find(id).destroy!
  redirect to('/')
end

post '/api/feedback' do
  halt 401 unless request.env['HTTP_APIKEY'] == settings.api_token
  content_type('application/json')
  hash = JSON.parse(request.body.read)
  Feedback.create!(author: hash.fetch('author', ''), text: hash.fetch('text'), sysinfo: hash.fetch('sysinfo', ''))
  201
rescue StandardError => e
  [422, JSON.generate(error: e.message)]
end
