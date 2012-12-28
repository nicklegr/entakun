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
end
