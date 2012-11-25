# coding: utf-8

require 'sinatra'
require 'sinatra/url_for'
require 'sinatra/reloader' if development?
require 'haml'
require 'coffee-script'
require './db'

set :haml, :format => :html5

get '/js/:basename.js' do
  CoffeeScript.compile erb(:"coffee/#{params[:basename]}.coffee"), { no_wrap: true }
end

get '/' do
  haml :index
end

get '/new_project' do
  project_key = SecureRandom.urlsafe_base64
  project = Project.create({ key: project_key, name: '新規プロジェクト' })
  project.staffs.create(name: '担当者1')

  redirect url_for("/projects/#{project_key}")
end

get '/project_name' do
  key = params[:project]

  project = Project.where(key: key).first
  project.name
end

post '/edit_project' do
  key = params[:project]
  name = params[:value]

  project = Project.where(key: key).first
  project.name = name
  project.save!

  name
end

get '/projects/:key' do
  @project_key = params[:key]

  @colors = [
    { name: 'orange' },
    { name: 'yellow' },
    { name: 'green' },
    { name: 'cyan' },
    { name: 'blue' },
    { name: 'pink' },
    { name: 'gray' },
  ]

  haml :project
end

get '/tasks' do
  key = params[:project]
  project = Project.where(key: key).first

  # order_by([[:complete, :asc], [:position, :asc], [:created_at, :asc]])を意図
  # なぜか複数のキーでorder_byできないので手動で
  project.tasks.sort{|a, b|
    if a.complete != b.complete
      ca = a.complete ? 1 : 0
      cb = b.complete ? 1 : 0
      ca <=> cb
    elsif a.position && b.position
      a.position <=> b.position
    elsif a.position
      -1
    elsif b.position
      1
    elsif a.created_at && b.created_at
      a.created_at <=> b.created_at
    else
      0
    end
  }.to_json
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
  task = project.tasks.create(name: name, complete: false, color: 'gray')

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

post '/color_task' do
  key = params[:project]
  id = params[:id]
  color = params[:color]

  project = Project.where(key: key).first
  task = project.tasks.find(id)
  task.color = color
  task.save!

  'OK'.to_json
end

post '/delete_task' do
  key = params[:project]
  id = params[:id]

  project = Project.where(key: key).first
  staff = project.staffs.where(task_id: id).first

  if staff
    # 割り当て済みなら割り当て解除
    Project.collection.find({ '_id' => project._id, 'staffs._id' => staff._id }).update(
      {
        "$pull"=>{"tasks"=>{ '_id' => Moped::BSON::ObjectId(id) } },
        "$unset"=>{"staffs.$.task_id"=>1},
      }
    )
  else
    project.tasks.find(id).destroy
  end

  'OK'.to_json
end

post '/complete_task' do
  key = params[:project]
  id = params[:task_id]

  project = Project.where(key: key).first
  task = project.tasks.find(id)
  task.complete = true
  task.completed_at = Time.now

  assigned_staff = project.staffs.where(task_id: id).first
  if assigned_staff
    assigned_staff.remove_attribute(:task_id)
  end

  project.save!

  'OK'.to_json
end

post '/task_sorted' do
  key = params[:project]
  order = params['task']

  project = Project.where(key: key).first
  order.each_with_index do |task_id, i|
    next if task_id == 'template'
    project.tasks.find(task_id).position = i
  end

  project.save!

  'OK'.to_json
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
  staff = project.staffs.create(name: name, color: 'orange') # @todo color rotation

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

post '/color_staff' do
  key = params[:project]
  id = params[:id]
  color = params[:color]

  project = Project.where(key: key).first
  staff = project.staffs.find(id)
  staff.color = color
  staff.save!

  'OK'.to_json
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

  # 複数人で使っている場合に、他の人が完了したタスクは割り当てられないようにする
  task = project.tasks.where(_id: task_id, complete: false).first
  if task
    # 誰かに割り当て済みならそちらを解除する
    old_staff = project.staffs.where(task_id: task_id).first
    if old_staff
      old_staff.remove_attribute(:task_id)
    end

    # 割り当て
    staff = project.staffs.find(staff_id)
    staff.task_id = task_id

    task.assigned_at = Time.now

    # 以上をアトミックに保存する
    project.save!
  end

  'OK'.to_json
end

post '/deassign_task' do
  key = params[:project]
  task_id = params[:task_id]

  project = Project.where(key: key).first
  staff = project.staffs.where(task_id: task_id).first
  staff.unset(:task_id)

  project.tasks.find(task_id).remove_attribute(:assigned_at)

  project.save!

  'OK'.to_json
end

get '/lookup_followees' do
  followees = params[:followees]
  result = []

  followees.each do |dummy, e|
    project = Project.where(key: e['project']).first

    staff_name = nil
    task_name = nil
    assigned_at = nil

    # staffは削除されてるかもしれない
    staff = project.staffs.where(id: e['staff']).first
    if staff
      staff_name = staff.name

      if staff.task_id
        # taskは確実にあるはず
        task = project.tasks.find(staff.task_id)
        task_name = task.name
        assigned_at = task.assigned_at
      end
    end

    result << e.update({ staff_name: staff_name, task_name: task_name, assigned_at: assigned_at })
  end

  result.to_json
end
