require 'bundler'

Bundler.setup
Bundler.require

require File.dirname(__FILE__) + "/web"

map '/assets' do
  run App.sprockets
end

map '/' do
  run App
end
