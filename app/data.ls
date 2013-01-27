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
  err, res <- v.callp \GetDoc type, key
  if err then return cb(err)

  if json = res[0][0]?.JSON
    cb null, JSON.parse(json)
  else
    cb!

# uses new api
export select-user = -> v.callp \select_user, ...arguments

export init-stubs = (cb = (->)) ->
  user =
    id         : 1
    name       : \intrepid_coderman
    created_at : now

  p = -> for ii from 1 to Math.ceil(Math.random!*5) # dummy data
    id    : ii
    date  : h.title-case h.elapsed-to-human-readable Math.random!*604800
    user  : user
    title : "Sub-post Title #{ii}"
    body  : h.ellipse 'hello world hello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello world hello world!' Math.ceil(Math.random!*120) 
 
  gen-posts = ->
    for i from 1 to 11
      id    : i
      title : "Post Title #{i}"
      date  : h.title-case h.elapsed-to-human-readable Math.random!*31446925
      user  : user
      posts : p!

  forums = for i from 1 to 4
    id          : i
    title       : "Forum #{i}"
    description : 'hello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello world!'
    posts       : gen-posts!

  homepage-stub = {forums}
  @put-doc \misc, \homepage, homepage-stub, false, cb
