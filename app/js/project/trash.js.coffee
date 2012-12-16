setup_trashbox = () ->
  $(".trashbox").droppable({
    tolerance: 'touch',
    activeClass: 'drop-here',

    activate: (event, ui) ->
      $('.trash-close').hide()
      $('.trash-open').show()
      $('.recycle-off').hide()
      $('.recycle-on').show()

    deactivate: (event, ui) ->
      $('.trash-close').show()
      $('.trash-open').hide()
      $('.recycle-off').show()
      $('.recycle-on').hide()

    drop: (event, ui) ->
      if showing_trashes()
        $.post(URL.recycle_task, { project: project_key, task_id: ui.draggable.data('id') })
        ui.draggable.removeClass('completed')
      else
        $.post(URL.complete_task, { project: project_key, task_id: ui.draggable.data('id') })
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

        $('.task').draggable('disable')
        $('.completed').draggable('enable')

        $('#task').attr('placeholder', '完了タスクを表示中')
        $('#task').attr('disabled', 'disabled')

        $('#trashbox-img .trash').hide()
        $('#trashbox-img .recycle').show()

        disable_staffs()
      else
        $('#tasks .task').not('#task-template').show()
        $('.completed').hide()

        $('.task').draggable('disable')

        $('#task').attr('placeholder', 'タスクを追加')
        $('#task').removeAttr('disabled')

        $('#trashbox-img .trash').show()
        $('#trashbox-img .recycle').hide()

        enable_staffs()
  )

showing_trashes = () ->
  $('#show_trashes_check').attr("checked")
