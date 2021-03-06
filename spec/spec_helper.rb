require 'bundler/setup'
require 'sinatra'
Sinatra::Application.environment = :test
Bundler.require :default, Sinatra::Application.environment
require 'rspec'
require 'capybara'
require 'capybara/rspec'
require 'capybara/poltergeist'

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

Capybara.javascript_driver = :poltergeist

# debug output
# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, { debug: true })
# end

Capybara.ignore_hidden_elements = false

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Capybara::DSL
end
