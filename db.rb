require 'mongoid'

class Project
  include Mongoid::Document
  field :key, type: String
  field :name, type: String
  embeds_many :tasks
  embeds_many :staffs
  validates_uniqueness_of :key
end

class Task
  include Mongoid::Document
  field :name, type: String
  field :complete, type: Boolean
  embedded_in :project
end

class Staff
  include Mongoid::Document
  field :name, type: String
  has_one :task
  embedded_in :project
end

Mongoid.configure do |config|
  if ENV.key?('MONGOHQ_URL')
    # for heroku
    config.sessions = { default: { uri: ENV['MONGOHQ_URL'] }}
  else
    config.sessions = { default: { database: 'entakun', hosts: [ 'localhost:27017' ] }}
  end
end
