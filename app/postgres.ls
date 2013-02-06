require! pg

conn-str = "tcp://postgres@localhost/pb"

export init = (cb = (->)) ->
  pg.connect conn-str, (err, c) ~>
    if err then return cb(err)
    @client = c

    # define closure function which has active connection
    @query = (sql, args, cb) ~>
      @client.query sql, args, (err, res) ->
        if err then return cb(err)
        # unwrap rows from result
        cb null, res.rows
    cb!

export select-users = (cb) ->
  @query "SELECT * FROM users LIMIT 1", [], cb
