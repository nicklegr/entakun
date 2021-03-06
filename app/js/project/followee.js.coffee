# in ms
if true
  followee_update_interval = 5 * 60 * 1000
  newest_time = 60 * 60 * 1000
  newer_time = 24 * 60 * 60 * 1000
else
  # for debug
  followee_update_interval = 5 * 1000
  newest_time = 10 * 1000
  newer_time = 20 * 1000

load_followees = () ->
  followees = $.cookie("entakun-followees")

  if followees == null
    followees = []

  followees

save_followees = (list) ->
  $.cookie("entakun-followees", list)

remove_followee = (project, staff) ->
  followees = load_followees()
  followees = $.grep(followees, (e) ->
    !(e['project'] == project && e['staff'] == staff)
  )
  save_followees(followees)

lookup_followees = () ->
  followees_data = []

  followees = load_followees()
  if followees.length > 0
    $.ajax({
      async: false,
      type: "GET",
      url: URL.lookup_followees,
      data: { followees: followees },
      dataType: 'json',
    }).done((data) ->
      followees_data = data
    )

  followees_data

interval_update_followees = () ->
  $("body").everyTime(followee_update_interval, () ->
    update_followees()
  )

setup_followees = () ->
  elems = $.grep($('#followees > .followee'), (e) ->
    $(e).attr('id') != 'followee-template'
  )
  $(elems).remove()

  followees_data = lookup_followees()
  $.each(followees_data, (i) ->
    elem = add_followee_html_bare(this.project, this.staff)
    update_followee(elem, this)
  )

update_followees = () ->
  followees_data = lookup_followees()
  $.each(followees_data, (i) ->
    data = this

    followee = $.grep($("#followees > .followee"), (e) ->
      if $(e).attr('id') == 'followee-template'
        false
      else
        $(e).data('followee')['project'] == data.project &&
        $(e).data('followee')['staff'] == data.staff
    )

    update_followee($(followee), data)
  )

add_followee_html_bare = (project_key, staff_id) ->
  # copy element
  new_followee = $('#followee-template').clone()
  new_followee.removeAttr('id') # don't set. to avoid dup id with staff
  new_followee.show()

  new_followee.data('followee', { project: project_key, staff: staff_id })
  new_followee.find('.task').data('name', '') # needed by setup_open_marker()

  # in-place delete
  name = new_followee.find('.followee-name')
  name.find('.delete').click(()->
    # remove cookie
    data = new_followee.data('followee')
    remove_followee(data['project'], data['staff'])

    # fade out
    $(this).parents('.followee').effect('fade', {}, 300, () ->
      $(this).remove()
    )
  )

  # show delete icon when mouse hover
  name.hover(
    () ->
      $(this).find('.delete').show()
    ,
    () ->
      $(this).find('.delete').hide()
  )

  setup_open_marker(new_followee.find('.task'))

  $("#followees").append(new_followee)
  new_followee

update_followee = (elem, data) ->
  unset_followee_new(elem)

  if data.staff_name
    elem.find('.followee-name > .name').text(data.staff_name + ' (' + data.project_name + ')')

    task = elem.find('.task')
    if data.task_name
      task.show()

      if data.task_name != task.data('name')
        # task name changed
        task.data('name', data.task_name)

        if is_task_opened(task)
          task.find('.name').text(data.task_name)
        else
          task.find('.name').text(get_first_line(data.task_name))

        if !is_long_name(task)
          init_open_marker(task)

        update_open_marker(task)

      # recent indicator
      if data.assigned_at
        assigned_time = Date.parse(data.assigned_at)
        now = new Date()

        if now - assigned_time < newest_time
          set_followee_newest(elem)
        else if now - assigned_time < newer_time
          set_followee_newer(elem)
    else
      # task deleted or unassigned
      task.hide()
  else
    # staff deleted
    elem.remove()
    remove_followee(data.project, data.staff)

set_followee_newest = (elem) ->
  unset_followee_new(elem)
  elem.find('.newest').show()

set_followee_newer = (elem) ->
  unset_followee_new(elem)
  elem.find('.newer').show()

unset_followee_new = (elem) ->
  elem.find('.newest, .newer').hide()
