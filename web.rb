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
  project = Project.create({ key: project_key, name: '新規プロジェクト' })
  project.tasks.create(name: 'タスク1')
  project.tasks.create(name: 'タスク2')
  project.staffs.create(name: '担当者1')
  project.staffs.create(name: '担当者2')

  redirect url_for("/projects/#{project_key}")
end

get '/projects/:key' do
  @project_key = params[:key]
  haml :project
end

get '/tasks' do
  key = params[:project]
  project = Project.where(key: key).first

  project.tasks.order_by('complete asc').to_json
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
  id = params[:id]
  name = params[:value]

  project = Project.where(key: key).first
  task = project.tasks.find(id)
  task.name = name
  task.save!

  name
end

post '/delete_task' do
  key = params[:project]
  id = params[:id]

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

  project.staffs.where(task_id: id).each do |e|
    e.unset(:task_id)
    e.save!
  end

  'OK'
end

get '/staffs' do
  key = params[:project]
  project = Project.where(key: key).first

  project.staffs.to_json
end

post '/new_staff' do
  key = params[:project]
  name = params[:name]

  project = Project.where(key: key).first
  staff = project.staffs.create(name: name)

  "#{staff._id}"
end

post '/edit_staff' do
  key = params[:project]
  id = params[:id]
  name = params[:value]

  project = Project.where(key: key).first
  staff = project.staffs.find(id)
  staff.name = name
  staff.save!

  name
end

post '/delete_staff' do
  key = params[:project]
  id = params[:id]

  project = Project.where(key: key).first
  project.staffs.find(id).destroy
end

post '/assign_task' do
  key = params[:project]
  task_id = params[:task_id]
  staff_id = params[:staff_id]

  project = Project.where(key: key).first
  task = project.tasks.find(task_id)
  staff = project.staffs.find(staff_id)

  unless staff.task_id
    staff.task_id = task._id
    staff.save!
  end

  'OK'
end

post '/deassign_task' do
  key = params[:project]
  task_id = params[:task_id]

  project = Project.where(key: key).first
  staff = project.staffs.where(task_id: task_id).first
  staff.unset(:task_id)
  staff.save!

  'OK'
end
