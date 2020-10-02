require 'sinatra'
require 'sinatra/activerecord'

class App < Sinatra::Base
  get '/' do
    erb :index, locals: { name: 'Oloasdfdlo'}
  end

  post '/feedback' do
    puts ::JSON.parse(request.body.read)
  end
end