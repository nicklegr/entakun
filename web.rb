# coding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'coffee-script'
require './db'

PROJECT_KEY = 'test_key'

set :haml, :format => :html5

get '/' do
  # @todo プロジェクト作成機能ができるまでの仮
  project = Project.where(key: PROJECT_KEY).first
  unless project
    Project.create({ key: PROJECT_KEY, name: 'test' })
  end

  haml :index
end

get '/js/application.js' do
  coffee :application
end

post '/new_task' do
  key = params[:project]
  name = params[:name]

  project = Project.where(key: key).first
  task = project.tasks.create(name: name)

  "#{task._id}"
end

post '/edit_task' do
  key = params[:project]
  id = params[:task_id]
  name = params[:value]

  project = Project.where(key: key).first
  task = project.tasks.find(id)
  task.name = name
  task.save!

  name
end
