require File.dirname(__FILE__) + '/spec_helper'

require 'project_helper'
require 'task_helper'

feature 'Project', js: true do
  background do
    DatabaseCleaner.clean

    project = Project.new_project('test_project')
    project.new_task('test task')

    visit '/projects/test_project'
  end

  scenario 'Copy Project' do
    from_project_key = Test::Project.new(page).key

    # copy project
    Test::Project.new(page).copy_project
    activate_last_window

    to_project_key = Test::Project.new(page).key

    expect(from_project_key).not_to eq(to_project_key) # assigned new url
    expect(Test::Task.first(page).name).to eq('test task') # task is also copied
  end

  scenario 'Edit Task in Copied Project' do
    from_project_key = Test::Project.new(page).key

    # copy project
    Test::Project.new(page).copy_project
    activate_last_window

    # edit task
    task = Test::Task.first(page)
    task.hover
    task.start_edit
    task.set_name 'edited task'
    task.end_edit

    # old project doesn't change
    visit "/projects/#{from_project_key}"
    expect(Test::Task.first(page).name).to eq('test task')
  end
end
