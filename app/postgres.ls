require! pg
require! \../shared/shared-helpers

export conn-str = "tcp://postgres@localhost/pb"

{map} = require \prelude-ls

# underscore foo_bar_car to camelcase fooBarCar
under2camel = (s) ->
  s.replace /_(\w)/gi, -> arguments[1].toUpperCase!

# assumes @query is populated (must call init)
# assumes all procs take one json argument and return a json response
init-proc = (proname) ->
  ls-name = under2camel(proname)
  @procs[ls-name] = ~>
    pargs = arguments[0 to -2].map(JSON.stringify)
    cb = arguments[arguments.length - 1]
    if typeof cb != 'function'
      throw new Error "Wrong arity for procedure #{ls-name}"

    pdollars = if pargs.length then [1 to pargs.length] else []
    pdollars = ["$#{i}" for i in pdollars].join(',')

    err, res <~ @query "SELECT procs.#{proname}(#{pdollars})", pargs
    if err then return cb(err)

    json = res[0][proname]
    cb null, shared-helpers.add-dates(JSON.parse(json))

init-procs = (cb = (->)) ->
  sql = '''
  SELECT proname
  FROM pg_catalog.pg_namespace n
  JOIN pg_catalog.pg_proc p ON pronamespace = n.oid
  WHERE nspname = 'procs'
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
  if err
    console.error \postgres, err
    return cb(err)
  err, res <- c.query sql, args
  if err then return cb(err)

  # unwrap rows from result
  cb null, res.rows

# connection only (raw queries)
export connect = pg.connect conn-str, _
