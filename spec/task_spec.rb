require File.dirname(__FILE__) + '/spec_helper'

feature 'Task', js: true do
  background do
    visit '/projects/59a596905494c60f' # @todo fixture
  end

  scenario 'Add task' do
    fill_in 'task', with: "task 1\n"
    page.should have_css('.task .name', text: 'task 1')
  end

  scenario 'Edit task' do
    task = page.first('.task.color-gray')
    page.execute_script('$(".task.color-gray").trigger("mouseenter")')
    task.find('.edit').click
    task.find('textarea').should be_visible

    task.find('textarea').set 'edit test'
    task.find('.ok').click

    task.find('.name').should have_text 'edit test'
  end

  scenario 'Complete task' do
    source = page.first('.task.color-gray')
    target = page.find('.trashbox')
    source.drag_to(target)

    source.should_not be_visible
  end

  scenario 'Show complete task' do
    source = page.first('.task.color-gray')
    target = page.find('.trashbox')
    source.drag_to(target)

    page.check('show_trashes_check')

    source.should be_visible
  end
end
