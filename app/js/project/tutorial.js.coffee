check_welcome_sequence = () ->
  if need_welcome_modal()
    show_welcome_modal()
    $.cookie('entakun-welcome-watched', true)
  else if need_bookmark_reminder()
    show_bookmark_reminder()

  # set on 'create project' button pressed
  $.removeCookie('entakun-project-created')

need_welcome_modal = () ->
  $.cookie('entakun-project-created') && !$.cookie('entakun-welcome-watched')

show_welcome_modal = () ->
  $('#project-url').val(window.location.href)

  $('#welcome').on('shown', () ->
    $('#project-url').select()
  )

  $('#welcome').on('hidden', show_turorial)

  $('#welcome').modal({
    backdrop: 'static',
  })

need_bookmark_reminder = () ->
  $.cookie('entakun-project-created') && $.cookie('entakun-welcome-watched')

show_bookmark_reminder = () ->
  $('#bookmark-reminder').oneTime(2000, () ->
    $(this).show('pulsate', { times: 3 }, 500, () ->
      $(this).oneTime(3000, () ->
        $(this).hide('fade', {}, 500)
      )
    )
  )

show_turorial = () ->
  $('#tutorial, .fade-plane').show('fade', 500)
  $('#tutorial, .fade-plane').one('click', () ->
    $('#tutorial, .fade-plane').hide('fade', 500)
  )