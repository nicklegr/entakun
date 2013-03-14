require File.dirname(__FILE__) + '/spec_helper'

require 'task_helper'

SHORT_NAME = 'hoge'
LONG_NAME = 'hoge' * 20
SHORT_AND_LONG_NAME = SHORT_NAME + "\n" + LONG_NAME

SHORT_URL = 'http://example.com/'
LONG_URL = 'http://example.com/dummy/very/very/very/very/very/very/very/long/url'

feature 'Task open/close', js: true do
  background do
    DatabaseCleaner.clean

    project = Project.new_project('test_project')
    project.new_task('test task')

    visit '/projects/test_project'
  end

  # ----------------------------------------

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
    expect(task.truncated?).to be_true
  end

  scenario 'Input short & long lines' do
    task = Test::Task.first(page)
    task.edit(SHORT_AND_LONG_NAME)

    expect(task.can_open?).to be_true
    expect(task.close?).to be_true
    expect(task.truncated?).to be_true
  end

  # ----------------------------------------

  scenario 'Open/Close task' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)

    task.toggle_open
    expect(task.open?).to be_true
    expect(task.truncated?).to be_false

    task.toggle_open
    expect(task.close?).to be_true
    expect(task.truncated?).to be_true
  end

  # ----------------------------------------

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
    expect(task.truncated?).to be_true
  end

  scenario 'Input short & long name when closed' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)

    task.edit(SHORT_AND_LONG_NAME)
    expect(task.can_open?).to be_true
    expect(task.close?).to be_true
    expect(task.truncated?).to be_true
  end

  # ----------------------------------------

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

  scenario 'Input short & long name when opened' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)
    task.toggle_open

    task.edit(SHORT_AND_LONG_NAME)
    expect(task.can_open?).to be_true
    expect(task.open?).to be_true
    expect(task.name).to eq(SHORT_AND_LONG_NAME.gsub("\n", ' ')) # 改行コードはスペースとして取得される
    expect(task.truncated?).not_to be_true
  end

  # ----------------------------------------

  scenario 'Edit long -> open -> edit short -> edit long' do
    task = Test::Task.first(page)
    task.edit(LONG_NAME)
    task.toggle_open

    task.edit(SHORT_NAME)
    task.edit(LONG_NAME)

    expect(task.can_open?).to be_true
    expect(task.close?).to be_true
    expect(task.truncated?).to be_true
  end

  # ----------------------------------------

  scenario 'Short URL linked' do
    task = Test::Task.first(page)
    task.edit(SHORT_URL)

    expect(task.truncated?).not_to be_true
    expect(task.elem).to have_link(SHORT_URL, href: SHORT_URL)
  end

  scenario 'Long URL truncated, but href is not truncated' do
    task = Test::Task.first(page)
    task.edit(LONG_URL)

    expect(task.truncated?).to be_true
    expect(task.elem).to have_link(LONG_URL, href: LONG_URL)
  end
end
