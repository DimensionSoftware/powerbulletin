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

  console.log "[pb-indexer] initialized!"
  cb!

first-run = true
# meant to be run as its own dedicated process
# it loops over records in the database
export run = ->
  console.log "[pb-indexer] running!" if first-run
  first-run := false

  # in the future adjust this batch-size differently in production,
  # increase as database server scales up and indexing volume increases
  # in dev we probably want the process to be a little less intense
  const batch-size = 4

  err, posts <- db.idx-posts batch-size
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
      console.warn "indexed posts: #{posts.map((.id)).join(',')}"
      process.next-tick run # try again!
  else
    set-timeout run, 500 # wait a bit before trying again
