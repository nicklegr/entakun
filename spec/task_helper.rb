require File.dirname(__FILE__) + '/spec_helper'

module Test
  class Project
    def initialize(page)
      @page = page
    end

    def show_trash
      @page.check('show_trashes_check')
    end

    def hide_trash
      @page.uncheck('show_trashes_check')
    end
  end

  class Task
    def self.first(page)
      new(page, page.first('.task.color-gray'))
    end

    def self.at(page, index)
      new(page, page.all('.task.color-gray')[index])
    end

    def initialize(page, task)
      @page = page
      @task = task
    end

    def hover
      id = @task[:id]
      @page.execute_script(%!$("##{id}").trigger("mouseenter")!)
    end

    def start_edit
      @task.find('.edit').click
    end

    def can_set_name?
      @task.find('textarea').visible?
    end

    def set_name(name)
      @task.find('textarea').set name
    end

    def end_edit
      @task.find('.ok').click
    end

    def toggle_complete
      target = @page.find('.trashbox')
      @task.drag_to(target)
    end

    # 現在の開閉状態で見えているタスク内容
    def name
      @task.find('.name').text
    end

    def visible?
      @task.visible?
    end

    def elem
      @task
    end
  end
end
