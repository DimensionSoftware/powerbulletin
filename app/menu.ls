require! {
  url
  path
}

# Find the path to the menu-item or return false.
#
# @param  Array   menu
# @param  Scalar  id      id of nested sortable item
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

# Return the path needed to insert or update a node with the given id.
#
# @param  Array   menu
# @param  Scalar  id      id of nested sortable item
# @return Array   path for menu-item
@path = (menu=[], id) -> @find(menu, id) or [menu.length]

# Insert or update a menu-item in a hierarchichal menu and return the new menu.
#
# @param  Array   menu    sites.config.menu (where the top-level is an array)
# @param  Array   p       path made of array indices (like [0, 1, 0, 5])
# @param  Object  object  object to add or merge at the given path
# @return Array   new menu
@mkpath = (menu=[], p=[], object={}) ->
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
      menu-item.children = @mkpath menu-item.children, rest, object
      return menu
    # ...there's nothing left, merge the object into menu-item
    else
      menu-item <<< object
      return menu

# Given a form submission, figure out what kind of data we have.
#
# @param  Object object   form data from menu admin
# @return Array  [type, data] should give you database-friendly info about the object
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
      slug        : forum-slug
      description : ''
  | \page =>
    type = \page
    data =
      site_id     : null
      path        : form.page-slug
      title       : title
      config      : JSON.stringify(main_content: form.content)
  | \external-link =>
    type = \external-link
    data = null
  | otherwise =>
    type = null
    data = null
  return [type, data]

# given an old and new menu hierarchy, move the menu-items that have moved
@move = (old-menu, new-menu) -> new-menu

# given and old and new menu hierarchy, reorder the menu-items that have been reordered at the same level
@reorder = (old-menu, new-menu) -> new-menu

# upsert a menu-item
@upsert = (site, object, cb) ->
  [type, data] = @extract object
  data.site_id = site.id

  do-upsert = (cb) ->
    switch type
    | \page          => db.pages.upsert data, cb
    | \forum         => db.forums.upsert data, cb # TODO - forum case is not so simple and will need to be expanded upon
    | \external-link => cb null, null
    | otherwise      => cb new Error("menu.upsert unknown type #type"), data

  do-upsert cb

# vim:fdm=indent
