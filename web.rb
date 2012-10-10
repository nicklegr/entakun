# coding: utf-8

require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/reloader' if development?
require 'haml'
require 'coffee-script'
require './db'

set :haml, :format => :html5

get '/js/application.js' do
  coffee erb(:"application.coffee")
end

get '/' do
  haml :index
end

get '/new_project' do
  project_key = SecureRandom.urlsafe_base64
  Project.create({ key: project_key, name: '新規プロジェクト' })
  redirect url_for("/projects/#{project_key}")
end

get '/projects/:key' do
  @project_key = params[:key]
  haml :project
end

get '/tasks' do
  key = params[:project]
  project = Project.where(key: key).first

  project.tasks.to_json
end

get '/incoming_tasks' do
  key = params[:project]
  project = Project.where(key: key).first

  project.tasks.where(complete: false).to_json
end

post '/new_task' do
  key = params[:project]
  name = params[:name]

  project = Project.where(key: key).first
  task = project.tasks.create(name: name, complete: false)

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

post '/delete_task' do
  key = params[:project]
  id = params[:task_id]

  project = Project.where(key: key).first
  project.tasks.find(id).destroy
end

post '/complete_task' do
  key = params[:project]
  id = params[:task_id]

  project = Project.where(key: key).first
  task = project.tasks.find(id)
  task.complete = true
  task.save!
end
