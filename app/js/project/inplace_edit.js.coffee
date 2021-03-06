enable_inplace_edit = (elem, edit_url, callback, disable_sortable) ->
  option = {
    submitdata : (value, settings) ->
      top_elem = find_object_top($(this))
      {
        project: project_key,
        id: top_elem.data('id'),
      }
    event: 'edit_event',
    cssclass: 'editing',
    select: true,
    callback: callback,
    onblur: 'submit', # 'ignore'
  }

  # http://stackoverflow.com/questions/9610041/can-the-onblur-event-be-used-with-jeditable-and-jquery-ui-sortable
  if disable_sortable
    option['onedit'] = disableSortable
    option['onsubmit'] = enableSortable
    option['onreset'] = enableSortable

  elem.find('.name').editable(edit_url, option)

  elem.find('.edit').click(()->
    $(this).prev().trigger('edit_event')
  )

  # show edit icons when mouse hover
  elem.hover(
    () ->
      $(this).find('.edit').show()
    ,
    () ->
      $(this).find('.edit').hide()
  )

enable_inplace_delete = (elem, delete_url) ->
  elem.find('.delete').click(()->
    top_elem = find_object_top($(this))

    $.ajax({
      async: true,
      type: "POST",
      url: delete_url,
      data: { project: project_key, id: top_elem.data('id') },
      dataType: 'json',
    })

    top_elem.effect('fade', {}, 300, () ->
      $(this).remove()
    )
  )

  # show edit icons when mouse hover
  elem.hover(
    () ->
      $(this).find('.delete').show()
    ,
    () ->
      $(this).find('.delete').hide()
  )

find_object_top = (elem) ->
  e = elem.parent()
  while true
    if e.attr('id')
      return e

    e = e.parent()

disableSortable = (settings, self) ->
  $("#tasks, .assigned-task").sortable('disable')

enableSortable = (settings, self) ->
  $("#tasks, .assigned-task").sortable('enable')
