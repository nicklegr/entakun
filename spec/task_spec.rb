require File.dirname(__FILE__) + '/task_helper'

feature 'Task', js: true do
  background do
    DatabaseCleaner.clean

    project = Project.new_project('test_project')
    project.new_task('test task')

    visit '/projects/test_project'
  end

  scenario 'Add task' do
    fill_in 'task', with: "task 1\n"
    Test::Task.at(page, 1).name.should == 'task 1'
  end

  scenario 'Edit task' do
    task = Test::Task.first(page)
    task.hover
    task.start_edit

    task.set_name 'edit test'
    task.end_edit
    task.name.should == 'edit test'
  end

  scenario 'Complete task' do
    task = Test::Task.first(page)
    task.complete

    task.should_not be_visible
  end

  scenario 'Show complete task' do
    task = Test::Task.first(page)
    task.complete
    Test::Project.new(page).show_trash

    task.should be_visible
  end
end
