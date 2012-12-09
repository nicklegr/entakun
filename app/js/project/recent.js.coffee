add_recent_project = (key) ->
  projects = load_recent_project()

  # move current project to last
  projects = $.grep(projects, (e) -> e != key)
  projects.push(key)

  save_recent_project(projects)

load_recent_project = () ->
  $.cookie("entakun-recent-project") || []

save_recent_project = (list) ->
  $.cookie("entakun-recent-project", list)
