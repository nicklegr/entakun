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
      $("ul#tasks").append('<li class="ui-state-default">' + text + '</li>')
      $("input#task").val('')
  )

  # trashbox
  $("#trashbox").droppable({
    tolerance: 'touch',
    drop: (event, ui) ->
      ui.draggable.remove()
  })
