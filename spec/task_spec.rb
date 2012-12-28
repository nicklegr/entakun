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
    expect(Test::Task.at(page, 1).name).to eq('task 1')
  end

  scenario 'Edit task' do
    task = Test::Task.first(page)
    task.hover
    task.start_edit
    expect(task.can_set_name?).to be_true

    task.set_name 'edit test'
    task.end_edit
    expect(task.name).to eq('edit test')
  end

  scenario 'Complete task' do
    task = Test::Task.first(page)
    task.toggle_complete

    expect(task).not_to be_visible
  end

  scenario 'Show complete task' do
    task = Test::Task.first(page)
    task.toggle_complete
    Test::Project.new(page).show_trash

    expect(task).to be_visible
  end
end
