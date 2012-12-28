require 'bundler/setup'
require 'sinatra'
Sinatra::Application.environment = :test
Bundler.require :default, Sinatra::Application.environment
require 'rspec'
require 'capybara'
require 'capybara/rspec'

require File.dirname(__FILE__) + '/../web'
disable :run

Capybara.app = Rack::Builder.new do
  map '/assets' do
    run App.sprockets
  end

  map '/' do
    run App
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Capybara::DSL
end
