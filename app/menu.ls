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

# Add nodes to a hierarchical menu object
#
# @param Array  menu      sites.config.menu (where the top-level is an array)
# @param String p         path; slugs separated by '/'
# @param Object object    object to add or merge at the given path
@mkpath = (menu=[], p='', object={}, uri-prefix='/') ->
  [first, ...rest] = p.split '/' |> reject (-> it is '')
  #console.log { first, rest, parts }

  # Do I have a menu item with it.slug part in menu?
  menu-item = find (.slug is first), menu
  console.log \menu-item, menu-item

  # Create menu-item if non-existent.
  if not menu-item
    console.log \slug, \not-menu-item, first
    new-item = { slug: first, uri: "#uri-prefix#first" }
    if rest.length
      console.log \--rest
      rest-path = rest.join '/'
      new-item.children = @mkpath rest-path, [], object, "#{new-item.uri}/"
      return [ ...menu, new-item ]
    else
      console.log \--leaf
      new-item <<< object
      return [ ...menu, new-item ]
  # If menu-item exists...
  else
    console.log \slug, \menu-item, first
    # ...and there's more to the path, add children
    if rest.length
      console.log \--rest
      menu-item.children ?= []
      rest-path = rest.join '/'
      menu-item.children = @mkpath rest-path, menu-item.children, object, "#{menu-item.uri}/"
      return menu
    # ...there's nothing left, merge the object into menu-item
    else
      menu-item <<< object
      return menu

# Make sense of the data given to us from the client side.
@extract = (object) ->
  if object.type
    return [object.type, object]
  if object?data?form?forum-slug
    type = \forum
    data =
      site_id: null
      parent_id: null
      title: \title
      uri: object.data.form.forum-slug
      slug: object.data.form.forum-slug
      description: ''
  else if object?data?form?page-slug
    type = \page
    data =
      site_id: null
      path: object.data.form.page-slug
      title: ''
      config: JSON.stringify(main_content: object.data.form.body)
  else if object?data?form?uri
    type = \external-link
    data = null
  return [type, data]

@add = (site, p, object, cb) ->
  menu = JSON.parse site.config.menu
  #new-menu = @mkpath(menu, p, object)
  [type, data] = @extract object
  data.site_id = site.id

  finish = (err, ...args) ->
    if err
      return cb err
    else
      return cb null, menu

  switch type
  | \forum         => @add-forum data, finish
  | \page          => @add-page data, finish
  | \external-link => cb null, new-menu

@add-forum = (forum, cb) ->
  # site_id
  # parent_id
  # title
  # uri
  # slug
  # description
  forum.slug ?= path.basename forum.uri
  db.forums.create data: forum, cb

@add-page = (page, cb) ->
  # site_id
  # path
  # title
  criteria = site_id: page.site_id, path: page.path
  err, existing-page <- db.pages.find-one { criteria }
  if err then return cb err
  if existing-page
    db.pages.update { criteria}, { data: page }, cb
  else
    db.pages.create { data: page }, cb

# vim:fdm=indent
