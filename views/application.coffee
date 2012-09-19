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

    activate: (event, ui) ->
      $('#trashbox-img').attr('src', '/img/TrashBox_Opened.png')

    deactivate: (event, ui) ->
      $('#trashbox-img').attr('src', '/img/TrashBox_Closed.png')

    drop: (event, ui) ->
      ui.draggable.remove()
      $('#trashbox-img').effect('bounce', {}, 150)
  })

  # in-place task edit
  $('.task').editable('/edit_task',{
    event: 'edit_event',
    cssclass: 'editing-task',
    # onblur: 'ignore'
  });

  $('.edit').click(()->
    $(this).prev().trigger('edit_event')
  )
