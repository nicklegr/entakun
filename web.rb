# coding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'coffee-script'

set :haml, :format => :html5

get '/' do
  haml :index
end

get '/js/application.js' do
  coffee :application
end
