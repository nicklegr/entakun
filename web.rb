require 'sinatra'
require 'coffee-script'

set :haml, :format => :html5

get '/' do
  haml :index
end

get '/js/application.js' do
  coffee :application
end
