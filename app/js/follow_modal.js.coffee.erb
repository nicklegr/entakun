setup_add_follow_modal = () ->
  $('#add-followee').on('show', () ->
    update_followee_submit_button()
  )

  $('#follow-url').submit(() ->
    url = $(this).find('input').val()
    project = url.replace(/// .+projects/ ///, '')
    send_data = "project=#{project}"

    # for after use
    $('#follow-members').find('input[name="project"]').val(project)

    # @todo show project title?

    # clear existing staff
    $('[id*="followee-select"]').empty()

    # get staff list
    $.get($(this).attr('action'), send_data, (data) ->
      $.each(data, (i) ->
        staff = this
        elem = $('#follow-member-template').clone()
        elem.removeAttr('id')
        elem.find('input').removeAttr('checked')
        elem.find('input').attr('name', staff['_id'])
        elem.find('span').text(staff['name'])
        elem.show()
        $('#followee-select-' + i).append(elem)
      )

      # update submit button when check state changed
      $('[id*="followee-select"] input').unbind('click')
      $('[id*="followee-select"] input').click(() ->
        update_followee_submit_button()
      )
    , 'json')

    return false
  )

  $('#follow-members').submit(()->
    follow_project_key = $(this).find('input[name="project"]').val()

    # save to cookie
    followees = load_followees()

    $(this).find('[id*="followee-select"] > label').each((i)->
      if $(this).find('input').attr('checked')
        staff_id = $(this).find('input').attr('name')

        # follow if not already followed
        if $.grep(followees, (e) -> e.project == follow_project_key && e.staff == staff_id).length == 0
          followees.push({ project: follow_project_key, staff: staff_id })
    )

    save_followees(followees)

    setup_followees()

    $('#add-followee').modal('hide')

    return false
  )

update_followee_submit_button = () ->
  enable = false

  $('[id*="followee-select"] input').each((i)->
    if $(this).attr('checked')
      enable = true
  )

  if enable
    $('#follow-members-submit').removeClass('disabled')
    $('#follow-members-submit').unbind('click')
    $('#follow-members-submit').click(()->
      $('#follow-members').submit()
    )
  else
    $('#follow-members-submit').addClass('disabled')
    $('#follow-members-submit').unbind('click')
