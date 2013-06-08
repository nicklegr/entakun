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

  def self.new_project(key)
    project = Project.create({ key: key, name: '新規プロジェクト' })
    project.staffs.create(name: '担当者1', color: COLORS.first)
    project
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
