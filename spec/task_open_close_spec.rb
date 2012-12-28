require File.dirname(__FILE__) + '/spec_helper'

require 'task_helper'

SHORT_NAME = 'hoge'
LONG_NAME = 'hoge' * 20

feature 'Task open/close', js: true do
  background do
    DatabaseCleaner.clean

    project = Project.new_project('test_project')
    project.new_task('test task')

    visit '/projects/test_project'
  end

  scenario 'Input short name' do
    task = Test::Task.first(page)
    task.edit(SHORT_NAME)

    expect(task.can_open?).not_to be_true
    expect(task.name).to eq(SHORT_NAME)
  end

  scenario 'Input long name' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)

    expect(task.can_open?).to be_true
    expect(task.close?).to be_true
    expect(task.name).not_to eq(LONG_NAME)
    expect(task.truncated?).to be_true
  end

  scenario 'Open/Close task' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)

    task.toggle_open
    expect(task.open?).to be_true
    expect(task.name).to eq(LONG_NAME)

    task.toggle_open
    expect(task.close?).to be_true
    expect(task.name).not_to eq(LONG_NAME)
    expect(task.truncated?).to be_true
  end

  scenario 'Input short name when closed' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)

    task.edit(SHORT_NAME)
    expect(task.can_open?).not_to be_true
    expect(task.name).to eq(SHORT_NAME)
  end

  scenario 'Input long name when closed' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)

    task.edit(LONG_NAME)
    expect(task.can_open?).to be_true
    expect(task.close?).to be_true
    expect(task.name).not_to eq(LONG_NAME)
    expect(task.truncated?).to be_true
  end

  scenario 'Input short name when opened' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)
    task.toggle_open

    task.edit(SHORT_NAME)
    expect(task.can_open?).not_to be_true
  end

  scenario 'Input long name when opened' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)
    task.toggle_open

    task.edit(LONG_NAME)
    expect(task.can_open?).to be_true
    expect(task.open?).to be_true
    expect(task.name).to eq(LONG_NAME)
    expect(task.truncated?).not_to be_true
  end

  scenario 'Edit long -> open -> edit short -> edit long' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)
    task.toggle_open

    task.edit(SHORT_NAME)
    task.edit(LONG_NAME)

    expect(task.can_open?).to be_true
    expect(task.close?).to be_true
    expect(task.name).not_to eq(LONG_NAME)
    expect(task.truncated?).to be_true
  end
end
