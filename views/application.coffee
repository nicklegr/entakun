$ ->
  # タスクリスト
  $("ul#tasks").sortable({
    connectWith: "ul.assigned-task"
  })
  $("ul#tasks").disableSelection()

  # 割り当て済みタスク
  $("ul.assigned-task").sortable({
    connectWith: "ul#tasks,ul.assigned-task",

    # 2つ以上のタスクは追加できないようにする
    receive: (event, ui) ->
      if $(this).find('li').length >= 2
        $(ui.sender).sortable('cancel');
  })
  $("ul.assigned-task").disableSelection()
