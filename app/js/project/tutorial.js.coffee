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

  # hide elements for simple view
  if showing_trashes()
    $('#tasks .task.completed').hide('fade', 500)
  else
    $('#tasks .task').not('#task-template, .completed').hide('fade', 500)

  $('.staff:gt(1)').hide('fade', 500) # don't hide first staff, for explain
  $('.assigned-task .task').hide('fade', 500) # hide first staff's task, for help message space

  $('.followee').not('#followee-template').hide('fade', 500)

  # click to close tutorial
  $('#tutorial, .fade-plane').one('click', () ->
    $('#tutorial, .fade-plane').hide('fade', 500)

    if showing_trashes()
      $('#tasks .task.completed').show('fade', 500)
    else
      $('#tasks .task').not('#task-template, .completed').show('fade', 500)

    $('.staff:gt(1)').show('fade', 500)
    $('.assigned-task .task').show('fade', 500)

    $('.followee').not('#followee-template').show('fade', 500)
  )
