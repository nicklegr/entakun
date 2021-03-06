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

    if this.task_ids
      $.each(this.task_ids, (i) ->
        task = $('#task_' + this)
        staff.find('.assigned-task').append(task)

        if task.data('assigned_at')
          assigned_time = Date.parse(task.data('assigned_at'))
          now = new Date()

          if now - assigned_time < newest_time
            set_staff_newest(staff)
          else if now - assigned_time < newer_time
            set_staff_newer(staff)
      )
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
    cursor: 'url(../img/Hand_on.cur), url(../img/Hand_on.png), default',
    containment: 'document',
    distance: 7,

    receive: (event, ui) ->
      if ui.item.hasClass('completed')
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
            staff_id: $(this).closest('.staff').data('id'),
          },
          dataType: 'json',
        })

        set_staff_newest($(this).closest('.staff'))

      # update event also called. So no need to call assigned_task_sorted() here

    update: (event, ui) ->
      if $(this).find('.task').length >= 2
        assigned_task_sorted($(this))

    stop: (event, ui) ->
      # if task was completed, hide and move to incoming list
      # should be in trashbox's drop handler, but there is timing problem
      if ui.item.hasClass('completed')
        if !$('#show_trashes_check').attr('checked')
          ui.item.hide()

        $('#tasks').prepend(ui.item)

        unset_staff_new($(this).closest('.staff'))

    remove: (event, ui) ->
      unset_staff_new($(this).closest('.staff'))
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
    $(this).parent().find('.name').trigger('edit_event')
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

  unset_staff_new(new_staff)

  $("#staffs").append(new_staff)
  new_staff

assigned_task_sorted = (elem) ->
  data = elem.sortable('serialize')
  data = "project=#{project_key}&" + data
  $.post(URL.task_sorted, data)

disable_staffs = () ->
  $('.staff-disabler').show('fade', 150)

enable_staffs = () ->
  $('.staff-disabler').hide('fade', 150)

set_staff_newest = (elem) ->
  unset_staff_new(elem)
  elem.find('.newest').show()

set_staff_newer = (elem) ->
  unset_staff_new(elem)
  elem.find('.newer').show()

unset_staff_new = (elem) ->
  elem.find('.newest, .newer').hide()
