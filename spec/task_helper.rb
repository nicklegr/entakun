module Test
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

    def edit(name)
      hover
      start_edit
      set_name name
      end_edit
    end

    def toggle_complete
      target = @page.find('.trashbox')
      @task.drag_to(target)
    end

    def toggle_open
      @task.find('.marker').click
    end

    def can_open?
      @task.find('.marker').visible?
    end

    def open?
      !@task.find('.task_open').visible? && @task.find('.task_close').visible?
    end

    def close?
      @task.find('.task_open').visible? && !@task.find('.task_close').visible?
    end

    # 開閉状態に関わらず、タスクの全文が返る
    def name
      @task.find('.name').text
    end

    # 現在の開閉状態で、タスクの内容が切り捨てられているかどうか
    def truncated?
      # この実装だと、「開いているけど切り捨てられている」という状況を検知できないけど、
      # その判定は難しいので保留する
      id = @task[:id]
      @page.evaluate_script(%!is_trancated($("##{id}"))!) && close?
    end

    def visible?
      @task.visible?
    end

    def elem
      @task
    end
  end
end
