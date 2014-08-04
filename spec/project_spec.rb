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
    # copy project
    Test::Project.new(page).copy_project
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)

    expect(current_url =~ %r|projects/[0-9a-f]+|).to be_true # assigned new url
    expect(Test::Task.first(page).name).to eq('test task') # task is also copied
  end

  scenario 'Edit Task in Copied Project' do
    current_url =~ %r|projects/(.+)|
    from_project_key = $1

    # copy project
    Test::Project.new(page).copy_project
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)

    current_url =~ %r|projects/(.+)|
    to_project_key = $1

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
