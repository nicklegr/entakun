check_tutorial = () ->
  if need_welcome_modal()
    show_welcome_modal()

  # set on 'create project' button pressed
  $.removeCookie('entakun-project-created')

need_welcome_modal = () ->
  $.cookie('entakun-project-created') && !$.cookie('entakun-welcome-watched')

show_welcome_modal = () ->
  $('#project-url').val(window.location.href)

  $('#welcome').on('shown', () ->
    $('#project-url').select()
  )

  $('#welcome').modal({
    backdrop: 'static',
  })

  $.cookie('entakun-welcome-watched', true)
