require! {
  url
}

export decode-menu-data = (o) ->
  path = "/?#{o.data.form}"
  o.data = url.parse path, true

export read = (json) ->
  menu0 = JSON.parse(json)
  menu1 = [ decode-menu-data m for m in menu0 ]

export type-of = (object) ->
  \forum

export add = (object, cb) ->
  type = type-of object
  switch type
  | \form          => add-forum object, cb
  | \page          => add-page object, cb
  | \external-link => add-external-link object, cb

export add-forum = (forum, cb) ->

export add-page = (page, cb) ->

export add-external-link = (external-link, cb) ->

