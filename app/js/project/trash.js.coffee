setup_trashbox = () ->
  $("#trashbox").droppable({
    tolerance: 'touch',

    activate: (event, ui) ->
      $('#trashbox-img').attr('src', ImageURL.trashbox_opened)

    deactivate: (event, ui) ->
      $('#trashbox-img').attr('src', ImageURL.trashbox_closed)

    drop: (event, ui) ->
      $.ajax({
        async: true,
        type: "POST",
        url: URL.complete_task,
        data: { project: project_key, task_id: ui.draggable.data('id') },
        dataType: 'json',
      })

      ui.draggable.addClass('completed')

      $('#trashbox-img').effect('bounce', {}, 150)
  })

setup_trash_toggle = () ->
  $('#show_trashes_check').change(() ->
      if $(this).attr("checked")
        $('#tasks .task').not('#task-template').hide()
        $('.completed').show()

        $('#task').attr('placeholder', '完了タスクを表示中')
        $('#task').attr('disabled', 'disabled')

      else
        $('#tasks .task').not('#task-template').show()
        $('.completed').hide()

        $('#task').attr('placeholder', 'タスクを追加')
        $('#task').removeAttr('disabled')
  )
