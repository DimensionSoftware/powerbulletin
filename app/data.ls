require! {
  h: './helpers'
  pg: './postgres'
}

# this file is intended to provide a high-level data interaction layer,
# decoupled from any particular datasource, whether it be voltdb or elastic
#
# the idea is the programmer shouldn't have to think too much about where the
# data is coming from to get work done from consuming this file

# all funs are assume to be callback functions

now = new Date

export forum-doc = (cb) ->
  @get-doc \misc, \forum, cb

export homepage-doc = (cb) ->
  @get-doc \misc, \homepage, cb

export add-post = (post, cb) ->
  pg.procs.add_post JSON.stringify(post), cb

export get-doc = (type, key, cb) ->
  err, res <- pg.procs.get_doc type, key
  if err then return cb(err)

  if json-res = res[0].get_doc
    cb null, JSON.parse(JSON.parse(json-res).json)
  else
    cb null, null

export put-doc = (type, key, val, cb) ->
  err <- pg.procs.put_doc type, key, JSON.stringify(val)
  if err then return cb(err)
  cb null

  #user =
  #  id         : 1
  #  name       : \intrepid_coderman
  #  created_at : now
#
#  p = -> for ii from 1 to Math.ceil(Math.random!*5) # dummy data
#    id    : ii
#    date  : h.title-case h.elapsed-to-human-readable Math.random!*604800
#    user  : user
#    title : "Sub-post Title #{ii}"
#    body  : h.ellipse 'hello world hello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello world hello world!' Math.ceil(Math.random!*120) 
# 
#  gen-posts = ->
#    for i from 1 to 10
#      id    : i
#      title : "Post Title #{i}"
#      date  : h.title-case h.elapsed-to-human-readable Math.random!*31446925
#      body  : h.ellipse 'hello world hello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello worldhello world hello world!' Math.ceil(Math.random!*75) 
#      user  : user
#      subposts : p!
#
#  gen-subforums = (id) ->
#    for i from 1 to 3
#      id          : id+"#{i}"
#      theme       : if i is 1 then \light else \dark # becomes a css class
#      title       : "SubForum #{i}"
#      slug        : "subforum-#{i}"
#      description : "Description for Forum #{i}"
#      posts       : []
#      #posts       : gen-posts!
#
#  forums = for i from 1 to 4
#    id          : i
#    theme       : if i is 1 then \light else \dark # becomes a css class
#    title       : "Forum #{i}"
#    slug        : "forum-#{i}"
#    description : "Description for Forum #{i}"
#    posts       : gen-posts!
#    subforums   : gen-subforums i
#
#  homepage-stub = {forums}
#  forum-stub    = {forums}
#
#  @put-doc \misc, \homepage, homepage-stub, false, cb
#  @put-doc \misc, \forum, forum-stub, false, cb
