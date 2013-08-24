require! {
  url
  path
}

# XXX moving to client
#export decode-menu-data = (o) ->
#  path = "/?#{o.data.form}"
#  o.data = url.parse path, true
#
#export read = (json) ->
#  menu0 = JSON.parse(json)
#  menu1 = [ decode-menu-data m for m in menu0 ]

@mkpath = (path='', config=[], object={}) ->
  [first, ...rest]:parts = path.split '/' |> reject (-> it is '')
  #console.log { first, rest, parts }

  # Do I have a menu item with it.slug part in config?
  menu-item = find (.slug is first), config
  console.log \menu-item, menu-item

  # Create menu-item if non-existent.
  if not menu-item
    console.log \not-menu-item
    config.push new-item = { slug: first }
    if rest.length
      console.log \--rest
      rest-path = rest.join '/'
      new-item.children = @mkpath rest-path, [], object
      return config
    else
      console.log \--leaf
      new-item <<< object
      return config
  #
  else
    console.log \menu-item
    if rest.length
      console.log \--rest
      menu-item.children ?= []
      rest-path = rest.join '/'
      menu-item.children = @mkpath rest-path, menu-item.children, object
      return config
    else
      console.log \--leaf
      config.push object
      return config

@type-of = (object) ->
  \forum

@add = (object, cb) ->
  type = type-of object
  switch type
  | \forum         => @add-forum object, cb
  | \page          => @add-page object, cb
  | \external-link => @add-external-link object, cb

@add-forum = (forum, cb) ->
  # site_id
  # parent_id
  # title
  # uri
  # slug
  # description
  forum.slug ?= path.basename forum.uri
  db.forums.create forum, cb

@add-page = (page, cb) ->
  # site_id
  # path
  # title
  db.pages.create page, cb

@add-external-link = (external-link, cb) ->
  cb new Error "not implemented"
