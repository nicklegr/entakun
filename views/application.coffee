add_task = (name) ->
  # copy element
  new_task = $('#task-template').clone()
  new_task.attr('id', '')
  new_task.find('.task').text(name)
  new_task.show()

  # in-place task edit
  new_task.find('.task').editable('/edit_task',{
    event: 'edit_event',
    cssclass: 'editing-task',
    # onblur: 'ignore'
  })

  new_task.find('.edit').click(()->
    $(this).prev().trigger('edit_event')
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
      ui.draggable.remove()
      $('#trashbox-img').effect('bounce', {}, 150)
  })

  # @todo test
  add_task('test 1')
  add_task('test 2')
  add_task('test 3')
  