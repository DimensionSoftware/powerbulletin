require! pg

conn-str = "tcp://postgres@localhost/pb"

# assumes @query is populated (must call init)
init-proc = (proname) ->
  @procs[proname] = ~>
    pargs = arguments[0 to -2]
    cb = arguments[arguments.length - 1]
    pdollars = if pargs.length then [1 to pargs.length] else []
    pdollars = ["$#{i}" for i in pdollars].join(',')
    #debug console log
    #console.log {pargs, pdollars, cb}
    @query "SELECT * FROM #{proname}(#{pdollars})", pargs, cb

init-procs = (cb = (->)) ->
  sql = '''
  SELECT  proname
  FROM    pg_catalog.pg_namespace n
  JOIN    pg_catalog.pg_proc p
  ON      pronamespace = n.oid
  WHERE   nspname = 'public'
  '''
  err, res <~ @query sql, []
  if err then return cb(err)
  pronames = map (.proname), res

  @procs ||= {} # init-proc expects this to be here
  for proname in pronames
    init-proc.call(@, proname)

  cb!

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
      return void
    init-procs.call @
    cb!

export select-users = (cb) ->
  @query "SELECT * FROM users LIMIT 1", [], cb
