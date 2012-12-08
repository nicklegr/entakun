show_welcome_modal = () ->
  $('#project-url').val(window.location.href)

  $('#welcome').on('shown', () ->
    $('#project-url').select()
  )

  $('#welcome').modal({
    backdrop: 'static',
  })
