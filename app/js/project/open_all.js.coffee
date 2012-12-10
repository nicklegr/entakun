setup_open_all_button = () ->
  update_open_all_button()

  $('#toggle-tasks').click(() ->
    if $('#open-all').is(':visible')
      listed_tasks().each(() ->
        if can_open_task($(this))
          if !is_task_opened($(this))
            open_task($(this))
      )
    else
      listed_tasks().each(() ->
        if can_open_task($(this))
          if is_task_opened($(this))
            close_task($(this))
      )
  )

update_open_all_button = () ->
  if any_task_can_open()
    $('#toggle-tasks').show()

    if any_task_opened()
      $('#open-all').hide()
      $('#close-all').show()
    else
      $('#open-all').show()
      $('#close-all').hide()
  else
    $('#toggle-tasks').hide()

any_task_can_open = () ->
  can_open_tasks = $.grep(listed_tasks(), (e) -> can_open_task($(e)))
  can_open_tasks.length >= 1

any_task_opened = () ->
  open_tasks = $.grep(listed_tasks(), (e) -> is_task_opened($(e)))
  open_tasks.length >= 1
