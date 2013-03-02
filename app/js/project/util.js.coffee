is_intersect = (elem1, elem2) ->
  x1 = [elem1.offset().left, elem1.offset().left + elem1.outerWidth()]
  x2 = [elem2.offset().left, elem2.offset().left + elem2.outerWidth()]
  y1 = [elem1.offset().top, elem1.offset().top + elem1.outerHeight()]
  y2 = [elem2.offset().top, elem2.offset().top + elem2.outerHeight()]

  x1[0] < x2[1] && x1[1] > x2[0] &&
  y1[0] < y2[1] && y1[1] > y2[0]

setup_resize_handler = () ->
  resize_timer = null
  $(window).resize(() ->
    clearTimeout(resize_timer)
    resize_timer = setTimeout(on_resize, 100)
  )

on_resize = () ->
  min_height = $(window).height() - $('.column-staffs-bottom').offset().top - 40

  $('.column-tasks-bottom').css('min-height', 0)
  task_height = $('.column-tasks-bottom').height()

  height = if task_height > min_height then task_height else min_height

  $('.column-tasks-bottom').css('min-height', height + 'px')
  $('.column-staffs-bottom').css('min-height', height + 'px')

url_regex = () ->
  /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/g

html_escape = (str) ->
  str = str.replace(/&/g, '&amp;')
  str = str.replace(/>/g, '&gt;')
  str = str.replace(/</g, '&lt;')
  str
