module Test
  class Project
    def initialize(page)
      @page = page
    end

    def key
      @page.current_url =~ %r|projects/(.+)|
      $1
    end

    def show_trash
      @page.check('show_trashes_check')
    end

    def hide_trash
      @page.uncheck('show_trashes_check')
    end

    def copy_project
      @page.find('button.copy-button').trigger('click')
    end
  end
end
