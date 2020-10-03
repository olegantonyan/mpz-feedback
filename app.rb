require 'sinatra'
require 'sinatra/activerecord'
require 'rack/attack'
require 'redis-store'
require_relative 'models/feedback'
require_relative 'models/config'
require_relative 'models/notification'

config = Config.new

set :environment, config.enviroment
set :login, config.get('LOGIN', 'oleg')
set :password, config.get('PASSWORD', '1234')
set :api_token, config.get('API_TOKEN', '1234')
set :cache_store, Redis::Store.new(url: config.get('REDIS_URL', 'redis://localhost:6379'))
set :database, { url: config.get('DATABASE_URL', 'postgres://app@localhost/mpz_feedback_development') }
set :telegram_api_key, config.get('TELEGRAM_API_KEY')
set :telegram_chat_id, config.get('TELEGRAM_CHAT_ID')

use Rack::Attack
Rack::Attack.cache.store = settings.cache_store
Rack::Attack.throttle('req/ip', limit: 100, period: 30.minutes) do |req|
  req.ip
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def hattr(text)
    Rack::Utils.escape_path(text)
  end

  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, 'Unauthorized'
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.login, settings.password]
  end

  def api_protected!
    return if api_authorized?
    halt 401
  end

  def api_authorized?
    request.env['HTTP_APIKEY'] == settings.api_token
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
  api_protected!
  content_type('application/json')
  hash = JSON.parse(request.body.read)
  Feedback.create!(author: hash.fetch('author', ''), text: hash.fetch('text'), sysinfo: hash.fetch('sysinfo', ''))
  Notification.new(telegram_api_key: settings.telegram_api_key, telegram_chat_id: settings.telegram_chat_id).send_message(hash.fetch('text'))
  201
rescue StandardError => e
  [422, JSON.generate(error: e.message)]
end
