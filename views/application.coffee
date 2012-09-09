$ ->
  $("ul#tasks").sortable({
    connectWith: "ul.assigned-task"
  })
  $("ul#tasks").disableSelection()

  $("ul.assigned-task").sortable({
    connectWith: "ul#tasks,ul.assigned-task",

    receive: (event, ui) ->
      if $(this).find('li').length >= 2
        $(ui.sender).sortable('cancel');
  })
  $("ul.assigned-task").disableSelection()
