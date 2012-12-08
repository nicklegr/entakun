#= require vender/jquery-ui-1.8.24.custom.min
#= require vender/jquery.ah-placeholder
#= require vender/jquery.jeditable
#= require vender/jquery.timers

#= require project/ajax
#= require project/follow_modal
#= require project/followee
#= require project/inplace_edit
#= require project/palette
#= require project/staff
#= require project/task
#= require project/titlebar
#= require project/trash
#= require project/tutorial
#= require project/util

$ ->
  # prevent XHR response caching by IE
  $.ajaxSetup({ cache: false })

  $.cookie.defaults['expires'] = 365 # @todo unlimited?
  $.cookie.json = true

  $('[placeholder]').ahPlaceholder({
    placeholderColor : 'silver',
    placeholderAttr  : 'placeholder',
    likeApple        : true
  })

  check_tutorial()

  setup_ajax_error_handler()

  setup_task_list()
  setup_task_input()

  load_tasks()
  load_staffs() # after load_tasks()
  setup_add_staff_link()

  setup_palette() # after load_tasks()

  setup_followees()
  interval_update_followees()

  setup_trashbox()
  setup_trash_toggle()

  setup_titlebar()

  setup_add_follow_modal()
