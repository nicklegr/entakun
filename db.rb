# coding: utf-8

require 'mongoid'
require './constant'

# おすすめindex
# db.projects.ensureIndex( { "key": 1 }, { unique: true } )

class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  field :key, type: String
  field :name, type: String
  embeds_many :tasks
  embeds_many :staffs
  validates_uniqueness_of :key

  def self.new_project(key = SecureRandom.hex(8))
    project = Project.create({ key: key, name: '新規プロジェクト' })
    project.staffs.create(name: '担当者1', color: COLORS.first)
    project
  end

  def self.copy_project(from_key, to_key = SecureRandom.hex(8))
    from_project = Project.where(key: from_key).first

    to_project = Project.create({ key: to_key, name: 'コピー - ' + from_project.name })
    to_project.tasks = from_project.tasks.select{|e| !e.complete}.dup
    to_project.staffs = from_project.staffs.dup
    to_project
  end

  def new_task(name)
    tasks.create(name: name, complete: false, color: 'gray')
  end
end

class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :color, type: String
  field :complete, type: Boolean

  # タスクの並び順。各リストの中でのインデックス。
  # つまりプロジェクト全体でユニークではない。
  # 例えば未割り当てタスクと割り当て済みタスクで同じ値になりうる。
  field :position, type: Integer

  field :assigned_at, type: Time
  field :completed_at, type: Time
  embedded_in :project
end

class Staff
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :color, type: String
  field :task_ids, type: Array # Moped::BSON::ObjectId # embedded docはhas_manyできないので
  embedded_in :project
end

Mongoid.configure do |config|
  if ENV.key?('MONGOLAB_URI')
    # for heroku
    config.sessions = { default: { uri: ENV['MONGOLAB_URI'] }}
  elsif ENV.key?('MONGODB_PORT_27017_TCP_ADDR')
    # for docker
    config.sessions = { default: { database: 'entakun', hosts: [ "#{ENV['MONGODB_PORT_27017_TCP_ADDR']}:27017" ] }}
  elsif test?
    config.sessions = { default: { database: 'entakun_test', hosts: [ 'localhost:27017' ] }}
  else
    config.sessions = { default: { database: 'entakun', hosts: [ 'localhost:27017' ] }}
  end
end

if development?
  Mongoid.logger.level = Logger::DEBUG
  Moped.logger.level = Logger::DEBUG
end
