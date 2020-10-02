require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/feedback'

get '/' do
  erb :index, locals: { items: Feedback.ordered }
end

post '/delete' do
  id = params.fetch('id')
  Feedback.find(id).destroy!
  redirect to('/')
end

post '/api/feedback' do
  content_type('application/json')
  hash = JSON.parse(request.body.read)
  Feedback.create!(author: hash.fetch('author', ''), text: hash.fetch('text'), sysinfo: hash.fetch('sysinfo', ''))
  201
rescue StandardError => e
  [422, JSON.generate(error: e.message)]
end
