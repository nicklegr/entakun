setup_titlebar = () ->
  update_project_title()
  enable_inplace_edit($('#project-name'), URL.edit_project, (value, settings) ->
    update_title(value)
  )
  $('.tutorial-button').click(() ->
    unless $(this).hasClass('disabled')
      show_turorial()
  )

update_project_title = () ->
  title = null
  $.ajax({
    async: false,
    type: "GET",
    url: URL.project_name,
    data: { project: project_key }
  }).done((data) ->
    title = data
  )

  $('#project-name').find('.name').text(title)
  update_title(title)

update_title = (title) ->
  document.title = title + ' - entakun'
