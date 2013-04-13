require! {
  async
  pg: './postgres'
  elastic: './elastic'
}

export init = (cb = (->)) ->
  process.title = \pb-indexer

  err <- pg.init
  if err then return cb err
  global.db = pg.procs

  err <- elastic.init
  if err then return cb err
  global.elc = elastic.client

  cb!

# meant to be run as its own dedicated process
# it loops over records in the database
export run = ->
  err, posts <- db.idx-posts 2
  if err then throw err

  common =
    index: \pb
    type: \post

  bulk-data = [{index: (common <<< {data.id, data})} for data in posts]

  ack = (post, cb) ->
    # ack index on db side
    db.idx-ack-post post.id, cb

  if posts.length
    err <- elc.bulk bulk-data
    if err then throw err

    async.each posts, ack, (err) ->
      if err then throw err
      #console.warn "indexed posts: #{posts.map((.id)).join(',')}"
      process.next-tick run # try again!
  else
    set-timeout run, 250 # wait a bit before trying again
