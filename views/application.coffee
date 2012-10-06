project_key = 'test_key'

add_task = (name) ->
  # send to server
  task_id = null
  $.ajax({
    async: false,
    type: "POST",
    url: "/new_task",
    data: { project: project_key, name: name }
  }).done((id) ->
    task_id = id
  )

  add_task_html(task_id, name)

add_task_html = (id, name) ->
  # copy element
  new_task = $('#task-template').clone()
  new_task.attr('id', id)
  new_task.find('.task').text(name)
  new_task.show()

  # in-place task edit
  new_task.find('.task').editable('/edit_task',{
    submitdata : (value, settings) ->
      {
        project: project_key,
        task_id: $(this).parent().attr('id'),
      }
    event: 'edit_event',
    cssclass: 'editing-task',
    # onblur: 'ignore'
  })

  new_task.find('.edit').click(()->
    $(this).prev().trigger('edit_event')
  )

  new_task.find('.delete').click(()->
    $.ajax({
      async: true,
      type: "POST",
      url: "/delete_task",
      data: { project: project_key, task_id: $(this).parent().attr('id') },
      dataType: 'json',
    })

    $(this).parent().effect('fade', {}, 300, () ->
      $(this).remove()
    )
  )

  $("ul#tasks").append(new_task)


$ ->
  # task list
  $("ul#tasks").sortable({
    connectWith: "ul.assigned-task"
  })
  $("ul#tasks").disableSelection()

  # assigned tasks
  $("ul.assigned-task").sortable({
    connectWith: "ul#tasks,ul.assigned-task",

    # Don't assign multiple tasks to one person
    receive: (event, ui) ->
      if $(this).find('li').length >= 2
        $(ui.sender).sortable('cancel');
  })
  $("ul.assigned-task").disableSelection()

  # task input
  $("input#task").keypress((event) ->
    text = $("input#task").val()

    if text != "" && (event.keyCode && event.keyCode == 13)
      add_task(text)
      $("input#task").val('')
  )

  # trashbox
  $("#trashbox").droppable({
    tolerance: 'touch',

    activate: (event, ui) ->
      $('#trashbox-img').attr('src', '/img/TrashBox_Opened.png')

    deactivate: (event, ui) ->
      $('#trashbox-img').attr('src', '/img/TrashBox_Closed.png')

    drop: (event, ui) ->
      # @todo notify server
      ui.draggable.remove()
      $('#trashbox-img').effect('bounce', {}, 150)
  })

  # get tasks
  tasks = null
  $.ajax({
    async: false,
    type: "GET",
    url: "/tasks",
    data: { project: project_key },
    dataType: 'json',
  }).done((data) ->
    tasks = data
  )

  $.each(tasks, (i) ->
    add_task_html(this._id, this.name)
  )
