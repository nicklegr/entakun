require File.dirname(__FILE__) + '/spec_helper'

module Test
  class Project
    def initialize(page)
      @page = page
    end

    def show_trash
      @page.find('#show_trashes_check').checked?.should == false
      @page.check('show_trashes_check')
    end

    def hide_trash
      @page.find('#show_trashes_check').checked?.should == true
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
      @task.find('textarea').visible?.should == true
    end

    def set_name(name)
      @task.find('textarea').set name
    end

    def end_edit
      @task.find('.ok').click
    end

    def complete
      @page.find('#show_trashes_check').checked?.should == false

      target = @page.find('.trashbox')
      @task.drag_to(target)
    end

    def recycle
      @page.find('#show_trashes_check').checked?.should == true

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
