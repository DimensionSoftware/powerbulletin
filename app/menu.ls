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

# Add form to a hierarchical menu object
@save-form-to-menu = (menu=[], id, form={}) ->
  item = find (.id is id), menu
  if item # base case -- found!
    item.form = form
  else
    for m in menu
      if m.children then @save-form-to-menu m.children, id, form
  if menu.length
    menu
  else
    [ form ]

# Given a menu and an id, return the path of the menu-item or false if not found
# @param  Array   menu
# @param  Scalar  id
# @param  Array   p
# @return Array   path for menu-item or false
@find = (menu=[], id, p=[]) ->
  #console.log "start", menu, p
  menu-item = find (.id is id), menu
  if menu-item
    #console.log [...p, menu.index-of menu-item]
    return [ ...p, menu.index-of(menu-item) ]
  else
    #console.log \not-found
    ndx-menu-pairs = menu |> map (.children) |> zip [0 to 100] |> filter (-> it.1)
    if ndx-menu-pairs.length
      #console.log \child-menus
      f = null
      found = find (([ndx, child-menu]) ~> f := @find child-menu, id, [...p, ndx]), ndx-menu-pairs
      if found
        #console.log \found-in-ndx-menu-pairs, found
        return f
      else
        #console.log \nope
        return false
    else
      #console.log \no-children, p
      return false

# Given a menu and an id, return the path needed to insert or update that node correctly.
# @param  Array   menu
# @param  Scalar  id
# @return Array   path for menu-item
@path = (menu=[], id) ->
  @find(menu, id) or [menu.length]

# Add nodes to a hierarchical menu object
#
# @param Array  p         path made of array indices (like [0, 1, 0, 5])
# @param Array  menu      sites.config.menu (where the top-level is an array)
# @param Object object    object to add or merge at the given path
@mkpath = (p=[], menu=[], object={}) ->
  #[first, ...rest] = p.split '/' |> reject (-> it is '')
  [first, ...rest] = p
  #console.log { first, rest }

  # Do I have a menu item with it.slug part in menu?
  #menu-item = find (.slug is first), menu
  menu-item = menu[first]
  #console.log \menu-item, menu-item

  # Create menu-item if non-existent.
  if not menu-item
    #console.log \slug, \not-menu-item, first
    new-item = { object.id, object.title, object.form }
    if rest.length
      throw new Error "path could not be created", p
      #console.log \--rest
      #new-item.children = @mkpath rest, [], object
      #return [ ...menu, new-item ]
    else
      #console.log \--leaf
      new-item <<< object
      return [ ...menu, new-item ]
  # If menu-item exists... update
  else
    #console.log \slug, \menu-item, first
    # ...and there's more to the path, add children
    if rest.length
      #console.log \--rest
      menu-item.children ?= []
      menu-item.children = @mkpath rest, menu-item.children, object
      return menu
    # ...there's nothing left, merge the object into menu-item
    else
      menu-item <<< object
      return menu

# Given a form submission, figure out what kind of data we have.
@extract = ({id,form,title}:object) ->
  if object.type
    return [object.type, object]
  switch form?dialog
  | \forum =>
    type = \forum
    data =
      site_id     : null
      parent_id   : null
      title       : title
      uri         : form.forum-slug
      slug        : forum-slug
      description : ''
  | \page =>
    type = \page
    data =
      site_id     : null
      path        : form.page-slug
      title       : title
      config      : JSON.stringify(main_content: object.data.form.body)
  | \external-link =>
    type = \external-link
    data = null
  | otherwise =>
    type = null
    data = null
  if form.id then data.id = form.id
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

