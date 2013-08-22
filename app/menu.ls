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
