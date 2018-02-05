# coding: utf-8

require 'sinatra/base'
require 'sinatra/url_for'
require 'sinatra/reloader' if development?
require 'sinatra/content_for'
require 'haml'
require 'coffee-script'
require './db'
require './constant'

Tilt::CoffeeScriptTemplate.default_bare = true

class App < Sinatra::Base
  helpers Sinatra::UrlForHelper
  register Sinatra::Contrib

  configure do
    mime_type :js, 'application/javascript'
    mime_type :json, 'application/json'
  end

  configure :development do
    register Sinatra::Reloader
  end

  set :root, File.dirname(__FILE__)
  set :views, root + '/views'
  set :public_folder, root + '/public'
  set :run, false # this line tells mongrel not to run and to let passenger handle the application

  set :haml, :format => :html5

  set :sprockets, Sprockets::Environment.new(root){ |environment|
    environment.append_path 'app/js'
    environment.append_path 'app/css'

    if ENV['RACK_ENV'] == 'production'
      environment.js_compressor  = YUI::JavaScriptCompressor.new(munge: true)
      environment.css_compressor = YUI::CssCompressor.new
    end
  }

  def next_color(staffs)
    # 次のスタッフの色を決定する
    # 最も使用回数が少ない色を選択。同数ならCOLORSの順で選ぶ
    color_count = {}
    COLORS.each do |e|
      color_count[e] = 0
    end

    staffs.each do |e|
      if e.color # @todo for compatibility. remove in the future
        color_count[e.color] += 1
      end
    end

    colors = []
    color_count.each do |k, v|
      colors << [k, v]
    end

    colors.sort! do |a, b|
      if a[1] == b[1]
        COLORS.index(a[0]) <=> COLORS.index(b[0])
      else
        a[1] <=> b[1]
      end
    end

    colors[0][0]
  end

  get '/js/:filename' do
    content_type :js
    CoffeeScript.compile erb(:"#{params[:filename]}.coffee"), { no_wrap: true }
  end

  get '/' do
    haml :index
  end

  post '/new_project' do
    project = Project.new_project()

    redirect url_for("/projects/#{project.key}")
  end

  post '/copy_project' do
    from_key = params[:project]
    new_project = Project.copy_project(from_key)

    redirect url_for("/projects/#{new_project.key}")
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
    @colors = COLORS

    haml :project
  end

  get '/tasks' do
    key = params[:project]
    project = Project.where(key: key).first

    # order_by([[:position, :asc], [:created_at, :desc]])を意図
    # なぜか複数のキーでorder_byできないので手動で
    tasks = project.tasks.where(complete: false).to_a.sort{|a, b|
      if a.position && b.position
        a.position <=> b.position
      elsif a.position
        1
      elsif b.position
        -1
      elsif a.created_at && b.created_at
        b.created_at <=> a.created_at
      else
        0
      end
    }

    completes = project.tasks.where(complete: true).order_by(completed_at: :desc)

    (tasks + completes).to_json
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
    task = project.new_task(name)

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
    staff = project.staffs.where({ :task_ids.in => [ id ] }).first

    if staff
      # 割り当て済みなら割り当て解除
      Project.collection.find({ '_id' => project._id, 'staffs._id' => staff._id }).update({
        "$pull" => {
          "tasks" => { '_id' => Moped::BSON::ObjectId(id) },
          "staffs.$.task_ids" => id,
        }
      })
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

    assigned_staff = project.staffs.where({ :task_ids.in => [ id ] }).first
    if assigned_staff
      assigned_staff.pull(:task_ids, id)
    end

    project.save!

    'OK'.to_json
  end

  post '/recycle_task' do
    key = params[:project]
    id = params[:task_id]

    project = Project.where(key: key).first
    task = project.tasks.find(id)
    task.complete = false
    task.remove_attribute(:completed_at)

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

    staffs = project.staffs
    staffs.each do |e|
      next unless e.task_ids
      e.task_ids.sort_by! do |id|
        project.tasks.find(id).position
      end
    end

    staffs.to_json
  end

  post '/new_staff' do
    key = params[:project]
    name = params[:name]

    project = Project.where(key: key).first
    staff = project.staffs.create(name: name, color: next_color(project.staffs))

    { id: staff._id, color: staff.color }.to_json
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
      old_staff = project.staffs.where({ :task_ids.in => [ task_id ] }).first
      if old_staff
        old_staff.pull(:task_ids, task_id)
      end

      # 割り当て
      staff = project.staffs.find(staff_id)
      staff.push(:task_ids, task_id)

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
    staff = project.staffs.where({ :task_ids.in => [ task_id ] }).first
    staff.pull(:task_ids, task_id)

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

        if staff.task_ids && staff.task_ids.size >= 1
          # taskは確実にあるはず
          task = project.tasks.find(staff.task_ids.first)
          task_name = task.name
          assigned_at = task.assigned_at
        end
      end

      result << e.update({
        project_name: project.name,
        staff_name: staff_name,
        task_name: task_name,
        assigned_at: assigned_at
      })
    end

    result.to_json
  end

  get '/recent_projects' do
    cookie = request.cookies['entakun-recent-project'] || '[]'
    keys = JSON.parse(cookie)

    @projects = keys.map do |e|
      project = Project.where(key: e).first
      if project
        { key: e, name: project.name }
      else
        nil
      end
    end

    @projects.compact!

    haml :recent_projects
  end

  get '/export_wekan' do
    # @todo 複数のプロジェクトのマージ
    key = params[:projects]

    project = Project.where(key: key).first

    to_label_id = {
      "orange" => "color_orange",
      "yellow" => "color_yellow",
      "green" => "color_lime",
      "cyan" => "color_sky",
      "blue" => "color_purple",
      "pink" => "color_pink",
      "gray" => nil,
    }

    @board_title = project.name
    @cards = project.tasks.map do |task|
      title = ""
      description = ""
      if task.name.match(/(.+?)\n(.+)/m)
        title = $1
        description = $2
      else
        title = task.name
        description = ""
      end

      {
        "_id" => task.id,
        "title" => title,
        "description" => description,
        "members" => [],
        "labelIds" => to_label_id[task.color] ? [ to_label_id[task.color] ] : [],
        "listId" => "Inbox", # staffに割り当てられてないカードはInboxへ
        "sort" => task.position || 0,
        "swimlaneId" => "gRArzLSPRcgag8HrC",
        "archived" => false,
        "createdAt" => "2018-02-04T13:22:59.022Z",
        "dateLastActivity" => "2018-02-04T13:22:59.022Z",
        "isOvertime" => false,
        "userId" => "WbgvtzpbZgvaQKTfo"
      }
    end

    @lists = [
      {
        "_id" => "Inbox",
        "archived" => false,
        "createdAt" => "2018-02-04T12:56:23.065Z",
        "title" => "Inbox",
        "wipLimit" => {
          "value" => 1,
          "enabled" => false,
          "soft" => false
        },
        "updatedAt" => "2018-02-04T12:56:23.068Z"
      },
    ]
    @lists += project.staffs.map do |staff|
      {
        "_id" => "staff_#{staff.id}",
        "archived" => false,
        "createdAt" => "2018-02-04T12:56:23.065Z",
        "title" => staff.name,
        "wipLimit" => {
          "value" => 1,
          "enabled" => false,
          "soft" => false
        },
        "updatedAt" => "2018-02-04T12:56:23.068Z"
      }
    end

    project.staffs.each do |staff|
      staff.task_ids.each do |task_id|
        assigned_card = @cards.find{|e| e["_id"].to_s == task_id.to_s}
        assigned_card["listId"] = "staff_#{staff.id}"
      end
    end

    @cards = @cards.to_json
    @lists = @lists.to_json

    content_type :json
    erb :"export_wekan.json", layout => false
  end
end
