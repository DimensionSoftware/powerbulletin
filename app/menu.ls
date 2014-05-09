require! {
  p: path
}

# Find the path to the menu-item or return false.
#
# @param  Array   menu
# @param  Scalar  id        id of nested sortable item
# @param  Array   p
# @return Array             path for menu-item or false
@path = (menu, id, p=[]) ->
  menu-item = find (.id is id), menu
  if menu-item
    #console.log [...p, menu.index-of menu-item]
    return [ ...p, menu.index-of(menu-item) ]
  else
    #console.log \not-found
    ndx-menu-pairs = menu |> map (.children) |> zip [0 to 200] |> filter (-> it.1)
    if ndx-menu-pairs.length
      #console.log \child-menus
      f = null
      found = find (([ndx, child-menu]) ~> f := @path child-menu, id, [...p, ndx]), ndx-menu-pairs
      if found
        #console.log \found-in-ndx-menu-pairs, found
        return f
      else
        #console.log \nope
        return false
    else
      #console.log \no-children, p
      return false

# Return the path needed to insert or update a node with the given id.
#
# @param  Array   menu
# @param  Scalar  id        id of nested sortable item
# @return Array             path for menu-item
@path-for-upsert = (menu, id) -> @path(menu, id) or [menu.length]

# Return the item at the given path
#
# @param  Array   menu      site menu
# @param  Array   path      path to item
# @return Object            menu item
@item = (menu, path) ->
  [first, ...rest] = path
  if rest.length
    return @item menu[first].children, rest
  else
    return menu[first]

# Return a menu with the given path deleted
# 
# @param  Array   menu      site menu
# @param  Array   path      path to item
# @return Array             menu without deleted path
@delete = (menu, path) ->
  [first, ...rest] = path
  new-menu = [] <<< menu
  if rest.length
    new-children = @delete new-menu[first].children, rest
    if new-children.length
      new-menu[first].children = new-children
    else
      first-child = {} <<< new-menu[first]
      delete first-child.children
      new-menu[first] = first-child
    return new-menu
  else
    new-menu.splice first, 1
    return new-menu

# Return a menu with the given object inserted in the given path
#
# @param  Array   menu      site menu
# @param  Array   path      path for new-item
# @param  Object  item      item to be inserted
# @return Array             new site menu with item inserted in path
@insert = (menu, path, item) ->
  [first, ...rest] = path
  new-menu = [] <<< menu
  if rest.length
    first-child = {} <<< new-menu[first]
    first-child.children = @insert new-menu[first].children, rest, item
    new-menu[first] = first-child
    return new-menu
  else
    new-menu.splice first, 0, item
    return new-menu

# Insert or update a menu-item in a hierarchichal menu and return the new menu.
#
# @param  Array   menu      sites.config.menu (where the top-level is an array)
# @param  Array   p         path made of array indices (like [0, 1, 0, 5])
# @param  Object  object    object to add or merge at the given path
# @return Array   new menu
@struct-upsert = (menu, p, object) ->
  #[first, ...rest] = p.split '/' |> reject (-> it is '')
  [first, ...rest] = p
  #console.log { first, rest }
  new-menu = [] <<< menu

  # Do I have a menu item with it.slug part in menu?
  #menu-item = find (.slug is first), menu
  menu-item = {} <<< new-menu[first]
  #console.log \menu-item, menu-item

  # Create menu-item if non-existent.
  if not menu-item
    #console.log \slug, \not-menu-item, first
    new-item = { object.id, object.title, object.form }
    if rest.length
      throw new Error "path could not be created", p
      #console.log \--rest
      #new-item.children = @struct-upsert rest, [], object
      #return [ ...menu, new-item ]
    else
      #console.log \--leaf
      new-item <<< object
      return [ ...new-menu, new-item ]
  # If menu-item exists... update
  else
    #console.log \slug, \menu-item, first
    # ...and there's more to the path, add children
    if rest.length
      #console.log \--rest
      menu-item.children = @struct-upsert menu-item.children, rest, object
      new-menu[first] = menu-item
      return new-menu
    # ...there's nothing left, merge the object into menu-item
    else
      #console.log \merge
      menu-item <<< object
      new-menu[first] = menu-item
      return new-menu

# Flatten a menu into a list of menu items
#
# @param  Array   menu      site menu
# @return Array             flattened list of menu items
@flatten = (menu) ->
  list = []
  for item in menu
    if item.children?length
      #console.log \recurse
      list = list.concat item, @flatten(item.children)
    else
      #console.log "concating #{item.id}"
      list = list.concat item
  #console.log \ids list.map (.id)
  list

# Given a form submission, figure out what kind of data we have.
#
# @param  Object  object    form data from menu admin
# @return Array             [type, data] should give you database-friendly info about the object
@extract = ({id,title,form}:object) ->
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
      slug        : p.basename form.forum-slug
  | \page =>
    type = \page
    data =
      site_id     : null
      path        : form.page-slug
      title       : title
      config      : { main_content: form.content, content-only: form.content-only }
  | \link =>
    type = \link
    data = {}
  | \placeholder =>
    type = \placeholder
    data = {}
  | otherwise =>
    type = null
    data = {}
  if form.dbid
    data.id = form.dbid
  else
    delete data.id
  return [type, data]

# Given a menu, and 2 paths, the first path will swap positions with the second path
#
# @param  Array   menu      sites.config.menu
# @param  Array   old-path  path of item to move
# @param  Array   path      path to move item to
# @return Array             new menu with 2 paths swapped
@move = (menu, old-path, path) ->
  item = @item menu, old-path
  d-menu = @delete menu, @path(menu, item.id)
  i-menu = @insert d-menu, path, item

# Return a nested-sortable-id generation function
#
# @param  Number    initial   initial value
# @return Function            function that returns incrementing values on every call
@id-fn = (initial) ->
  i = initial
  ->
    i++

# Given a menu tree from db.menu(site-id, cb), return a tree suitable for site.config.menu
#
# @param  Array   old-menu  original-style menu of hierarchical forums
# @return Array             new-style menu
@upconvert = (old-menu, id-fn) ->
  if not id-fn
    id-fn = @id-fn 1

  _item = (old-item) ->
    id    : id-fn!to-string!
    title : old-item.title
    form  :
      dialog     : \forum
      dbid       : old-item.id
      title      : old-item.title
      forum-slug : old-item.uri
      page-slug  : ''
      content    : ''
      uri        : ''

  _convert = (old-item) ~>
    if old-item?forums?length
      item = _item old-item
      item.children = @upconvert old-item.forums, id-fn
      return item
    else
      return _item old-item

  old-menu.map _convert

#### ^^^^ Everything above this line can be shared with the client if necessary. ^^^^ ####

# Upsert a menu-item into the database
#
# @param  Object    site    site
# @param  Object    object  raw menu item
# @param  Function  cb      function to run after database upsert
@db-upsert = (site, object, cb) ->
  [type, data] = @extract object
  data.site_id = site.id

  switch type
  | \page          =>
    if not data?path
      return cb errors: [ "Slug is required." ]
    if not data.path.match /^\//
      return cb errors: [ "Slug must begin with /" ]
    db.pages.upsert data, (err, data) ->
      if err and err.routine.match /unique/
        err.message = "Slug is already taken"
      cb err, data
  | \forum         =>
    if not data?uri
      return cb errors: [ "Slug is required." ]
    if not data.uri.match /^\//
      return cb errors: [ "Slug must begin with /" ]
    db.forums.upsert data, (err, data) ->
      # TODO - forum case is not so simple and will need to be expanded upon
      if err and err.routine.match /unique/
        err.message = "Slug is already taken."
      cb err, data
  | \link          => cb null, []
  | \placeholder   => cb null, []
  | otherwise      => cb new Error("menu.upsert unknown type #type"), data

# Delete an object referenced by a menu-item from the database.
#
# @param  Object    object  menu item to delete; children are not automatically deleted
# @param  Function  cb      function to run after deletions have completed
@db-delete = (object, cb) ->
  [type, data] = @extract object
  if (type is \page or type is \forum) and not data.id
    cb new Error("no id in data")

  switch type
  | \page          =>
    query = { id: data.id, path: data.path }
    db.pages.soft-delete query, cb
  | \forum         =>
    query = { id: data.id, uri: data.uri }
    db.forums.soft-delete query, cb
  | \link          => cb null, []
  | \placeholder   => cb null, []
  | otherwise      => cb null, []

# vim:fdm=indent
