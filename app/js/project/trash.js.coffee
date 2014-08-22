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
        ui.draggable.removeClass('completed')
        $('#tasks').prepend(ui.draggable) # move to first
        $.post(URL.recycle_task, { project: project_key, task_id: ui.draggable.data('id') }, () ->
          # update position of recycled task
          task_sorted()
        )
      else
        ui.draggable.addClass('completed')
        $.post(URL.complete_task, { project: project_key, task_id: ui.draggable.data('id') })

      update_trash_count()

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
  # Firefox saves checkbox state, so reset it
  $('#show_trashes_check').removeAttr('checked')
  $('#task').removeAttr('disabled')

  $('#show_trashes_check').change(trash_mode_changed)

  $('#trashbox-img').click(() ->
    checkbox = $('#show_trashes_check')
    checkbox.prop("checked", !checkbox.prop("checked"))

    trash_mode_changed()
  )

trash_mode_changed = () ->
  if showing_trashes()
    $('#tasks .task').not('#task-template').hide()
    $('.completed').show()

    $('.task').draggable('disable')
    $('.completed').draggable('enable')

    $('#task').attr('placeholder', '完了タスクを表示中')
    $('#task').attr('disabled', 'disabled')

    $('.tutorial-button').addClass('disabled')

    $('#trashbox-img .trash').hide()
    $('#trashbox-img .recycle').show()

    $('#trash-count').hide()

    # 完了タスクを印刷する際は、
    # スタッフリストを非表示にし、タスクをセンタリングする
    $('.column-tasks').addClass('print-task-only')
    $('.column-staffs').addClass('no-print')

    disable_staffs()
  else
    $('#tasks .task').not('#task-template').show()
    $('.completed').hide()

    $('.task').draggable('disable')

    $('#task').attr('placeholder', 'タスクを追加')
    $('#task').removeAttr('disabled')

    $('.tutorial-button').removeClass('disabled')

    $('#trashbox-img .trash').show()
    $('#trashbox-img .recycle').hide()

    $('#trash-count').show()

    $('.column-tasks').removeClass('print-task-only')
    $('.column-staffs').removeClass('no-print')

    enable_staffs()

  update_open_all_button()

showing_trashes = () ->
  $('#show_trashes_check').attr("checked")

update_trash_count = () ->
  # ignore ui-helper element
  count = $('.completed').not('.ui-draggable-dragging').length
  count = '' if count == 0
  $('#trash-count').html(count)
