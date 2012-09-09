$ ->
  $("ul#tasks").sortable({
    connectWith: "ul.assigned-task"
  })
  $("ul#tasks").disableSelection()

  $("ul.assigned-task").sortable({
    connectWith: "ul#tasks,ul.assigned-task"
  })
  $("ul.assigned-task").disableSelection()
