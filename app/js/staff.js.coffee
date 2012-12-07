load_staffs = () ->
  staffs = null
  $.ajax({
    async: false,
    type: "GET",
    url: URL.staffs,
    data: { project: project_key },
    dataType: 'json',
  }).done((data) ->
    staffs = data
  )

  $.each(staffs, (i) ->
    # @todo for compatibility. remove in the future
    color = this.color || 'orange'

    staff = add_staff_html(this._id, this.name, color)

    if this.task_id
      staff.find('.assigned-task').append($('#task_' + this.task_id))
  )

setup_add_staff_link = () ->
  $('#add-staff').click(add_staff_event)

add_staff_event = () ->
  name = window.prompt('名前を入力してください')
  if name
    add_staff(name)

add_staff = (name) ->
  # send to server
  staff_id = null
  color = null
  $.ajax({
    async: false,
    type: "POST",
    url: URL.new_staff,
    data: { project: project_key, name: name },
    dataType: 'json',
  }).done((data) ->
    staff_id = data['id']
    color = data['color']
  )

  add_staff_html(staff_id, name, color)

add_staff_html = (id, name, color) ->
  # copy element
  new_staff = $('#staff-template').clone()
  new_staff.attr('id', 'staff_' + id)
  new_staff.data('id', id)

  new_staff.find('.staff-name').addClass('color-' + color)
  new_staff.find('.name').text(name)

  new_staff.show()

  # assigned tasks
  new_staff.find(".assigned-task").sortable({
    connectWith: "#tasks,.assigned-task",
    helper: "clone", # prevent firing click event on dragging
    cursor: 'url(../img/Hand_on.png), default',
    distance: 7,

    receive: (event, ui) ->
      if $(this).find('.task').length >= 2
        # Don't assign multiple tasks to one person
        $(ui.sender).sortable('cancel')
      else if ui.item.hasClass('completed')
        # avoid completed task assign
        $(ui.sender).sortable('cancel')
      else
        $.ajax({
          async: true,
          type: "POST",
          url: URL.assign_task,
          data: {
            project: project_key,
            task_id: ui.item.data('id'),
            staff_id: $(this).parent().data('id'),
          },
          dataType: 'json',
        })

    stop: (event, ui) ->
      # if task was completed, hide and move to incoming list
      # should be in trashbox's drop handler, but there is timing problem
      if ui.item.hasClass('completed')
        if !$('#show_trashes_check').attr('checked')
          ui.item.hide()

        $('#tasks').append(ui.item)
  })

  staff_name = new_staff.find('.staff-name')

  staff_name.find('.name').editable(
    (value, settings) ->
      top_elem = find_object_top($(this))

      if !top_elem.data('deleted')
        data = {
          project: project_key,
          id: top_elem.data('id'),
          value: value,
        }

        $.post(URL.edit_staff, data)

      value
    ,
    {
      event: 'edit_event',
      cssclass: 'editing',
      select: true,
      onblur: 'submit', # 'ignore'
      onedit: () -> find_object_top($(this)).find('.delete').show(),
      onsubmit: () -> find_object_top($(this)).find('.delete').hide(),
      onreset: () -> find_object_top($(this)).find('.delete').hide(),
    }
  )

  staff_name.find('.edit').click(()->
    $(this).prev().trigger('edit_event')
  )

  # show edit icons when mouse hover
  staff_name.hover(
    () ->
      $(this).find('.edit').show()
    ,
    () ->
      $(this).find('.edit').hide()
  )

  enable_inplace_delete(new_staff, URL.delete_staff) # reuse code
  new_staff.unbind('hover') # but not hover
  new_staff.find('.delete').click(() -> find_object_top($(this)).data('deleted', true) )

  $("#staffs").append(new_staff)
  new_staff
