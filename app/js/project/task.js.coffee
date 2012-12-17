task_name_max_width = 310

setup_task_list = () ->
  $("#tasks").sortable({
    connectWith: ".assigned-task",
    cancel: ".completed", # disable sorting completed tasks
    helper: "clone", # prevent firing click event on dragging
    cursor: 'url(../img/Hand_on.png), default',
    containment: 'document',
    distance: 7,

    receive: (event, ui) ->
      $.ajax({
        async: true,
        type: "POST",
        url: URL.deassign_task,
        data: { project: project_key, task_id: ui.item.data('id') },
        dataType: 'json',
      })

    update: (event, ui) ->
      # task count without template element
      if $("#tasks > .task").length - 1 >= 2
        data = $("#tasks").sortable('serialize')
        data = "project=#{project_key}&" + data
        $.post(URL.task_sorted, data)

    stop: (event, ui) ->
      # if task was completed, hide and move to last
      # should be in trashbox's drop handler, but there is timing problem
      if ui.item.hasClass('completed')
        if !$('#show_trashes_check').attr('checked')
          ui.item.hide()

        $('#tasks').append(ui.item)
  })

setup_task_input = () ->
  $("input#task").keypress((event) ->
    text = $("input#task").val()

    if text != "" && (event.keyCode && event.keyCode == 13)
      add_task(text)
      $("input#task").val('')
  )

  # focus on page load
  # must be after .keypress()
  $("input#task").focus()

load_tasks = () ->
  tasks = null
  $.ajax({
    async: false,
    type: "GET",
    url: URL.tasks,
    data: { project: project_key },
    dataType: 'json',
  }).done((data) ->
    tasks = data
  )

  $.each(tasks, (i) ->
    task = add_task_html(this._id, this.name, this.color)
    if this.complete
      task.addClass('completed')
      if !$('#show_trashes_check').attr('checked')
        task.hide()
  )

add_task = (name) ->
  # send to server
  task_id = null
  $.ajax({
    async: false,
    type: "POST",
    url: URL.new_task,
    data: { project: project_key, name: name }
  }).done((id) ->
    task_id = id
  )

  add_task_html(task_id, name, default_color)

  # adjust border length
  on_resize()

add_task_html = (id, name, color) ->
  # copy element
  new_task = $('#task-template').clone()

  new_task.data('id', id)
  new_task.data('name', name)

  new_task.attr('id', 'task_' + id)
  new_task.addClass('color-' + color)
  new_task.find('.name').text(limit_task_name_len(name))
  new_task.show()

  setup_open_marker(new_task)

  # delete button
  enable_inplace_delete(new_task, URL.delete_task) # reuse code
  new_task.unbind('hover') # but not hover
  new_task.find('.delete').click(() -> enableSortable()) # and extra handler

  # click edit icon -> comment edit
  new_task.find('.edit').click(()->
    new_task.find('.comment').val(new_task.data('name'))
    begin_edit_task($(this).closest('.task'))
  )

  # show edit icon when mouse hover
  enable_edit_hover(new_task)

  # comment edit window
  new_task.find('.btn.cancel').click(() ->
    end_edit_task(new_task)
  )
  new_task.find('.btn.ok').click(() ->
    # update task title & internal data
    org_name = new_task.find('.comment').val()
    new_task.data('name', org_name)

    if is_task_opened(new_task)
      new_task.find('.name').text(org_name)
    else
      new_task.find('.name').text(limit_task_name_len(org_name))

    if !is_trancated(org_name)
      init_open_marker(new_task)

    update_open_marker(new_task)

    end_edit_task(new_task) # after marker update

    # send to server
    $.post(URL.edit_task,
      { project: project_key, id: new_task.data('id'), value: org_name }
    )
  )

  # keyboard shortcut
  new_task.find('.comment').keydown((e) ->
    # Ctrl+Enter, Cmd+Enter means OK
    if (e.ctrlKey || e.metaKey) && e.keyCode == 13
      new_task.find('.btn.ok').click()

    # ESC means Cancel
    if e.keyCode == 27
      new_task.find('.btn.cancel').click()
  )

  # for recycle drag
  new_task.draggable({
    revert: 'invalid',
    revertDuration: 0,
    helper: 'clone',
    cursor: 'url(../img/Hand_on.png), default',
    containment: 'document',
    distance: 7,
    zIndex: 100,
    start: (event, ui) -> $(this).css('visibility', 'hidden')
    stop: (event, ui) ->
      if $(this).hasClass('completed')
        # restore
        $(this).css('visibility', 'visible')
      else
        # hide if recycled
        $(this).css('visibility', 'visible')
        $(this).hide()
  })
  new_task.draggable('disable')

  $("#tasks").append(new_task)

  new_task

listed_tasks = () ->
  if showing_trashes()
    $('#tasks .task.completed')
  else
    $('#tasks .task').not('#task-template, .completed')

setup_open_marker = (elem) ->
  init_open_marker(elem)
  update_open_marker(elem)

  elem.find('.name, .marker').click(() ->
    if is_painting()
      return

    task = $(this).closest('.task')

    if can_open_task(task)
      if is_task_opened(task)
        close_task(task)
      else
        open_task(task)
  )

update_open_marker = (elem) ->
  if is_trancated(elem.data('name'))
    elem.find('.marker').show()
  else
    elem.find('.marker').hide()

init_open_marker = (elem) ->
  elem.find('.marker').hide()
  elem.find('.task_open').show()
  elem.find('.task_close').hide()

open_task = (task) ->
  if !can_open_task(task)
    throw new Error("Can't open task #{task.data('id')}: content is single line")

  task.find('.name').text(task.data('name'))
  task.find('.task_open').hide()
  task.find('.task_close').show()
  update_open_all_button()

close_task = (task) ->
  if !can_open_task(task)
    throw new Error("Can't close task #{task.data('id')}: content is single line")

  task.find('.name').text(limit_task_name_len(task.data('name')))
  task.find('.task_open').show()
  task.find('.task_close').hide()
  update_open_all_button()

can_open_task = (elem) ->
  elem.find('.marker').is(":visible")

is_task_opened = (elem) ->
  elem.find('.task_close').is(":visible")

is_trancated = (name) ->
  name != limit_task_name_len(name)

limit_task_name_len = (name) ->
  ret = name.replace(/\n[\s\S]*$/, "") # get first line
  ret = truncate_by_width(ret, task_name_max_width, $('#ruler'))
  ret

begin_edit_task = (elem) ->
  end_paint() # if in paint mode, cancel it

  disableSortable()
  disable_edit_hover(elem)

  elem.find('.name-box').hide()
  elem.find('.edit-box').show()
  elem.find('.comment').select()

end_edit_task = (elem) ->
  enableSortable()
  enable_edit_hover(elem)

  elem.find('.name-box').show()
  elem.find('.edit-box').hide()

  # if openable task appeared/disappeared, show/hide button
  # must be after showing .name-box
  update_open_all_button()

enable_edit_hover = (elem) ->
  elem.hover(
    () ->
      $(this).find('.edit').show()
    ,
    () ->
      $(this).find('.edit').hide()
  )

disable_edit_hover = (elem) ->
  elem.unbind('hover')
  elem.find('.edit').hide()
