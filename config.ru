require 'bundler'

Bundler.setup
Bundler.require

path = File.dirname(__FILE__)
require path + "/web.rb"

set :root, path
set :views, path + '/views'
set :public_folder, path + '/public'
set :run, false # this line tells mongrel not to run and to let passenger handle the application
# set :environment, :development
set :raise_errors, true 

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/js'
  run environment
end

map '/' do
  run Sinatra::Application
end
