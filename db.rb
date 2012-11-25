require 'mongoid'

class Project
  include Mongoid::Document
  include Mongoid::Timestamps
  field :key, type: String
  field :name, type: String
  embeds_many :tasks
  embeds_many :staffs
  validates_uniqueness_of :key
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
  field :task_id, type: Moped::BSON::ObjectId # embedded docはhas_oneできないので
  embedded_in :project
end

Mongoid.configure do |config|
  if ENV.key?('MONGOLAB_URI')
    # for heroku
    config.sessions = { default: { uri: ENV['MONGOLAB_URI'] }}
  else
    config.sessions = { default: { database: 'entakun', hosts: [ 'localhost:27017' ] }}
  end
end

# Mongoid.logger.level = Logger::DEBUG
# Moped.logger.level = Logger::DEBUG
