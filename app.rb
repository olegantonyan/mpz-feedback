require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/feedback'

class App < Sinatra::Base
  get '/' do
    erb :index, locals: { items: Feedback.ordered }
  end

  post '/feedback' do
    content_type('application/json')
    hash = JSON.parse(request.body.read)
    Feedback.create!(author: hash.fetch('author', ''), text: hash.fetch('text'), sysinfo: hash.fetch('sysinfo', ''))
    201
  rescue StandardError => e
    [422, JSON.generate(error: e.message)]
  end
end
