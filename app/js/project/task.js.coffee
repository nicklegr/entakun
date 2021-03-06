TASK_OPEN_TIME_FAST = 100
TASK_OPEN_TIME_SLOW = 200

setup_task_list = () ->
  $("#tasks").sortable({
    connectWith: ".assigned-task",
    cancel: ".completed", # disable sorting completed tasks
    helper: "clone", # prevent firing click event on dragging
    cursor: 'url(../img/Hand_on.cur), url(../img/Hand_on.png), default',
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
        task_sorted()

    stop: (event, ui) ->
      # if task was completed, hide and move to last
      # should be in trashbox's drop handler, but there is timing problem
      if ui.item.hasClass('completed')
        if !$('#show_trashes_check').attr('checked')
          ui.item.hide()

        $('#tasks').prepend(ui.item)
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
    task = add_task_html(this._id, this.name, this.color, this.assigned_at)
    task.appendTo(task.parent()) # preserve order
    if this.complete
      task.addClass('completed')
      if !$('#show_trashes_check').attr('checked')
        task.hide()
  )

  update_trash_count()

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

  add_task_html(task_id, name, default_color, null)

  # adjust border length
  on_resize()

add_task_html = (id, name, color, assigned_at) ->
  # copy element
  new_task = $('#task-template').clone()

  new_task.data('id', id)
  new_task.data('name', name)
  new_task.data('assigned_at', assigned_at)

  new_task.attr('id', 'task_' + id)
  new_task.addClass('color-' + color)
  new_task.find('.name').html(short_task_name(name))
  new_task.show()

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
    end_edit_task(new_task)

    # update task title & internal data
    org_name = new_task.find('.comment').val()
    new_task.data('name', org_name)

    if is_task_opened(new_task)
      new_task.find('.name').html(full_task_name(org_name))
    else
      new_task.find('.name').html(short_task_name(org_name))

    if !is_long_name(new_task)
      init_open_marker(new_task)

    update_open_marker(new_task)

    update_open_all_button() # after marker update

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
    cursor: 'url(../img/Hand_on.cur), url(../img/Hand_on.png), default',
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

  $("#tasks").prepend(new_task)

  # checks if task name is truncated,
  # so must be after layouted (after prepend())
  setup_open_marker(new_task)

  new_task

task_sorted = () ->
  data = $("#tasks").sortable('serialize')
  data = "project=#{project_key}&" + data
  $.post(URL.task_sorted, data)

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
  if is_long_name(elem)
    elem.find('.marker').show()
  else
    elem.find('.marker').hide()

init_open_marker = (elem) ->
  elem.find('.marker').hide()
  elem.find('.task_open').show()
  elem.find('.task_close').hide()

open_task = (task, time = TASK_OPEN_TIME_FAST) ->
  if !can_open_task(task)
    throw new Error("Can't open task #{task.data('id')}: content is single line")

  name = task.find('.name')

  close_height = name.outerHeight(true)

  name.html(full_task_name(task.data('name')))
  name.addClass('opened')
  task.find('.task_open').hide()
  task.find('.task_close').show()

  open_height = name.outerHeight(true)

  name.css('height', close_height + 'px')
  name.animate({height: open_height + 'px'}, time, 'swing', () ->
    name.css('height', '')
  )

  update_open_all_button()

close_task = (task, time = TASK_OPEN_TIME_FAST) ->
  if !can_open_task(task)
    throw new Error("Can't close task #{task.data('id')}: content is single line")

  name = task.find('.name')

  open_height = name.outerHeight(true)

  name.html(short_task_name(task.data('name')))
  name.removeClass('opened')
  task.find('.task_open').show()
  task.find('.task_close').hide()

  close_height = name.outerHeight(true)

  name.css('height', open_height + 'px')
  name.animate({height: close_height + 'px'}, time, 'swing', () ->
    name.css('height', '')
  )

  update_open_all_button()

can_open_task = (elem) ->
  elem.find('.marker').is(":visible")

is_task_opened = (elem) ->
  elem.find('.task_close').is(":visible")

# 現在のタスク内容は、切り捨てが発生するような長さか？
# 判定結果は、タスクの開閉状態に依存しない
#
# elemが画面内に表示されている必要がある
is_long_name = (elem) ->
  # 2行以上あれば必ず切り捨てられる
  name = elem.data('name')
  if get_first_line(name) != name
    return true

  # 1行の場合、切り詰められるか判定するために、一旦閉じた状態にする
  name_elem = elem.find('.name')
  opened = name_elem.hasClass('opened')

  if opened
    name_elem.removeClass('opened')

  name_elem_raw = elem.find('.name')[0]
  result = name_elem_raw.offsetWidth < name_elem_raw.scrollWidth

  if opened
    name_elem.addClass('opened')

  result

short_task_name = (name) ->
  link_url(html_escape(get_first_line(name)))

full_task_name = (name) ->
  link_url(html_escape(name))

get_first_line = (name) ->
  name.replace(/\n[\s\S]*$/, "") # get first line

link_url = (name) ->
  name.replace(url_regex(), '<a href="$&" target="_blank" onclick="avoid_open_task(arguments[0])">$&</a>')

avoid_open_task = (event) ->
  event.stopPropagation()

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
