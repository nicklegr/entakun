require 'bundler'

Bundler.setup
Bundler.require

path = File.dirname(__FILE__)
require path + "/web.rb"

Tilt::CoffeeScriptTemplate.default_bare = true

set :root, path
set :views, path + '/views'
set :public_folder, path + '/public'
set :run, false # this line tells mongrel not to run and to let passenger handle the application

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'app/js'
  environment.append_path 'app/css'

  if ENV['RACK_ENV'] == 'production'
    environment.js_compressor  = YUI::JavaScriptCompressor.new(munge: true)
    environment.css_compressor = YUI::CssCompressor.new
  end

  run environment
end

map '/' do
  run Sinatra::Application
end
