require! pg

conn-str = "tcp://postgres@localhost/pb"

# assumes @query is populated (must call init)
init-proc = (proname) ->
  @procs[proname] = ~>
    pargs = arguments[0 to -2]
    cb = arguments[arguments.length - 1]
    pdollars = if pargs.length then [1 to pargs.length] else []
    pdollars = ["$#{i}" for i in pdollars].join(',')

    err, res <- @query "SELECT * FROM #{proname}(#{pdollars})", pargs
    if err then return cb(err)

    json = res[0][proname]
    cb null, JSON.parse(json)

init-procs = (cb = (->)) ->
  sql = '''
  SELECT proname
  FROM pg_catalog.pg_namespace n
  JOIN pg_catalog.pg_proc p ON pronamespace = n.oid
  WHERE nspname = 'public'
    AND prorettype='json'::regtype
  '''
  err, res <~ @query sql, []
  if err then return cb(err)
  pronames = map (.proname), res

  @procs ||= {} # init-proc expects this to be here
  for proname in pronames
    init-proc.call(@, proname)

  cb!

export init = (cb = (->)) ->
  # initialize procs from pg
  # and materialize them into real nodejs funs
  init-procs.call @, cb

export query = (sql, args, cb) ->
  err, c <- pg.connect conn-str
  if err then return cb(err)
  err, res <- c.query sql, args
  if err then return cb(err)

  # unwrap rows from result
  cb null, res.rows

export select-users = (cb) ->
  @query "SELECT * FROM users LIMIT 1", [], cb
