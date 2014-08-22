require File.dirname(__FILE__) + '/spec_helper'

require 'project_helper'
require 'task_helper'

feature 'Index', js: true do
  background do
    DatabaseCleaner.clean
    visit '/'
  end

  scenario 'New Project' do
    find('button.start-button').click
    project_key = Test::Project.new(page).key
    expect(project_key).to match(/[0-9a-f]+/)
  end
end
