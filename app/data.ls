require! {
  h: './helpers'
  v: './voltdb'
}

# this file is intended to provide a high-level data interaction layer,
# decoupled from any particular datasource, whether it be voltdb or elastic
#
# the idea is the programmer shouldn't have to think too much about where the
# data is coming from to get work done from consuming this file

# all funs are assume to be callback functions

now = new Date

# this will eventually pull from (either postgresql or voltdb) docs table
# for now its a STUB
export homepage-doc = (cb) ->
  @get-doc \misc, \homepage, cb

export add-post = (post, cb) ->
  v.add-post(post, cb)

# uses new api
export put-doc = (type, key, doc, index-enabled, cb) ->
  # unary + casts bool to int
  v.callp \PutDoc type, key, JSON.stringify(doc), +index-enabled, cb

export get-doc = (type, key, cb) ->
  err, json <- v.callp \GetDoc type, key
  if err then return cb(err)
  cb null, JSON.parse(json[0][0].JSON)

export init-stubs = (cb = (->)) ->
  user =
    name       : \anonymous
    created_at : now

  posts = for i to 4 # dummy data
    date    : h.title-case h.elapsed-to-human-readable Math.random!*604800
    user    : user
    message : h.ellipse 'hello world!' 6

  topics = for i to 5 # dummy data
    title : \Test
    date  : h.title-case h.elapsed-to-human-readable Math.random!*31446925
    user  : user
    posts : posts

  homepage-stub = {topics}
  @put-doc \misc, \homepage, homepage-stub, false, cb
