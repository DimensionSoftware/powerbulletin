require! {h: './helpers'}

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

  stub = {topics}

  cb null, stub

