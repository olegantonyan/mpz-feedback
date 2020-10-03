require 'sinatra'
require 'sinatra/activerecord'
require 'rack/attack'
require 'redis-store'
require_relative 'models/feedback'

LOGIN = ENV.fetch('LOGIN')
PASSWORD = ENV.fetch('PASSWORD')
API_TOKEN = ENV.fetch('API_TOKEN')

use Rack::Attack
Rack::Attack.cache.store = Redis::Store.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
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
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [LOGIN, PASSWORD]
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
  halt 401 unless request.env['HTTP_APIKEY'] == API_TOKEN
  content_type('application/json')
  hash = JSON.parse(request.body.read)
  Feedback.create!(author: hash.fetch('author', ''), text: hash.fetch('text'), sysinfo: hash.fetch('sysinfo', ''))
  201
rescue StandardError => e
  [422, JSON.generate(error: e.message)]
end
