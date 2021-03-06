default_color = 'gray'

setup_palette = () ->
  $('.color-box').click((event) ->
    start_paint($(this))
    event.stopPropagation() # prevent firing $('body') click event
  )

  # cancel button
  $('#color-cancel').click(end_paint)

  # click outside task -> cancel
  $('body').click(end_paint)

  # ESC to cancel
  $('body').keypress((event) ->
    if event.keyCode == 27
      end_paint()
  )

start_paint = (elem) ->
  color = elem.data('color-name')

  # highlight current color
  $('.color-box').removeClass('color-focus')
  elem.addClass('color-focus')

  # cancel button
  $('#color-cancel').show()

  # change mouse cursor
  reset_mouse_cursor()
  $('body').addClass('brush-' + color)

  # click on task -> change color
  tasks = $('#tasks > .task, .assigned-task > .task')
  tasks.unbind('click')
  tasks.bind('click', (event) ->
    if $('.color-focus').length == 1
      color = set_color($(this))

      $.post(URL.color_task,
        { project: project_key, id: $(this).data('id'), color: color }
      )

      event.stopPropagation() # prevent firing $('body') click event
  )

  # click on staff -> change color
  $('.staff-name').unbind('click')
  $('.staff-name').bind('click', (event) ->
    if $('.color-focus').length == 1
      color = set_color($(this))

      $.post(URL.color_staff,
        { project: project_key, id: $(this).closest('.staff').data('id'), color: color }
      )

      event.stopPropagation() # prevent firing $('body') click event
  )

end_paint = () ->
  $('.color-box').removeClass('color-focus')
  $('#color-cancel').hide()
  reset_mouse_cursor()

is_painting = () ->
  $('.color-focus').length == 1

set_color = (elem) ->
  elem.removeClass('color-orange color-yellow color-green color-cyan color-blue color-pink color-gray')

  color_name = $('.color-focus').data('color-name')
  elem.addClass('color-' + color_name)

  color_name

reset_mouse_cursor = () ->
  $('body').removeClass('brush-orange brush-yellow brush-green brush-cyan brush-blue brush-pink brush-gray')

  # automatically added by sortable
  $('body').css('cursor', '')
