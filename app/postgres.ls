require! pg

conn-str = "tcp://postgres@localhost/pb"

# assumes @query is populated (must call init)
# assumes all procs take one json argument and return a json response
init-proc = (proname) ->
  @procs[proname] = (args, cb = (->)) ~>
    err, res <- @query "SELECT * FROM #{proname}($1)", [JSON.stringify(args)]
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
