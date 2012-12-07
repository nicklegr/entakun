# thx to http://d.hatena.ne.jp/Psychs/20070525/1180077269
get_extent = (str, ruler) ->
  e = $(ruler)
  e.empty()

  width = e.text(str).get(0).offsetWidth;
  e.empty()

  width

truncate_by_width = (str, max_width, ruler) ->
  if str.length == 0
    return ''

  if get_extent(str, ruler) <= max_width
    return str

  i = 0
  while i < str.length
    s = str.slice(0, i) + '...';
    if get_extent(s, ruler) > max_width
      return str.slice(0, i - 1) + '...';
    i++

  return ''
