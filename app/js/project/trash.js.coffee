setup_trashbox = () ->
  $(".column-trash").droppable({
    tolerance: 'touch',
    activeClass: 'drop-here',

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

      if is_intersect($('#trashbox-img'), ui.helper)
        # hide immediately
        $('#trashbox-img').effect('bounce', {}, 150)
      else
        # move to trashbox, and hide
        helper_clone = ui.helper.clone()
        helper_clone.appendTo(ui.helper.parent())

        helper_clone.position(
          of: '#trashbox-img',
          using: (coord, feedback) ->
            coord.opacity = 0.3
            helper_clone.animate(coord, 300, () ->
              $(this).remove()
              $('#trashbox-img').effect('bounce', {}, 150)
            )
        )
  })

setup_trash_toggle = () ->
  $('#show_trashes_check').change(() ->
      if showing_trashes()
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

showing_trashes = () ->
  $('#show_trashes_check').attr("checked")
