require! {
  async
  pg
  debug
  \fs
  orm: \thin-orm
  postgres: \./postgres
}

{filter, join, keys, values} = require \prelude-ls

logger = debug \thin-orm

export orm    = orm
export client = { connect: (cb) -> pg.connect postgres.conn-str, cb }
export driver = orm.create-driver \pg, { pg: client, logger }

export-model = ([t, cs]) ->
  orm.table(t).columns(cs)
  module.exports[t] = orm.create-client driver, t

get-tables = (dbname, cb) ->
  sql = '''
  SELECT table_name
  FROM information_schema.tables
  WHERE table_catalog=$1
    AND table_schema='public'
  '''
  err, rows <- postgres.query sql, [dbname]
  if err then return cb(err)
  cb null, rows.map (.table_name)

get-cols = (dbname, tname, cb) ->
  sql = '''
  SELECT ordinal_position, column_name
  FROM information_schema.columns
  WHERE table_catalog=$1 AND table_name=$2 AND table_schema='public'
  ORDER BY ordinal_position asc
  '''
  err, rows <- postgres.query sql, [dbname, tname]
  if err then return cb(err)
  cb null, rows.map (.column_name)

insert-statement = (table, obj) ->
  columns   = keys obj
  value-set = [ "$#{i+1}" for k,i in columns ].join ', '
  vals      = values obj
  return ["INSERT INTO #table (#columns) VALUES (#value-set) RETURNING *", vals]

update-statement = (table, obj, wh) ->
  wh       ?= "WHERE id = $1"
  ks        = keys obj |> filter (-> it isnt \id)
  obj-vals  = [ obj[k] for k in ks ]
  value-set = [ "#k = $#{i + 2}" for k,i in ks].join ', '
  vals      = [obj.id, ...obj-vals]
  return ["UPDATE #table SET #value-set #wh RETURNING *", vals]

# generate an upsert function for the given table name
# @param String table   name of table
# @returns Function     an upsert function for the table
upsert-fn = (table) ->
  (object, cb) ->
    do-insert = (cb) ->
      [insert-sql, vals] = insert-statement table, object
      postgres.query insert-sql, vals, cb
    do-update = (cb) ->
      [update-sql, vals] = update-statement table, object
      postgres.query update-sql, vals, cb

    if not object.id
      return do-insert cb

    err, r <- postgres.query "SELECT * FROM #table WHERE id = $1", [ object.id ]
    if r.length
      do-update cb
    else
      do-insert cb

# This is for queries that don't need to be stored procedures.
# Base the top-level key for the table name from the FROM clause of the SQL query.
query-dictionary =
  # db.users.all cb
  users:
    all: postgres.query 'SELECT * FROM users', [], _
    email-in-use: ({email}, cb) ->
      err, r <- postgres.query 'SELECT COUNT(*) AS c FROM users WHERE email = $1', [email]
      if err then return cb err
      cb null, !!r.0.c

  pages:
    upsert: upsert-fn \pages

  posts:
    moderated: (forum-id, cb) ->
      postgres.query '''
      SELECT *
      FROM posts p
      JOIN moderations m ON m.post_id=p.id
      WHERE p.forum_id=$1
      ''', [forum-id], cb

  forums:
    upsert: upsert-fn \forums


# assumed postgres is initialized
export init = (cb) ->
  err, tables <~ get-tables \pb, _
  if err then return cb(err)
  err, colgroups <~ async.map tables, (get-cols \pb, _, _)
  if err then return cb(err)
  schema = zip tables, colgroups

  # query db and create export-model
  each export-model, schema

  # XXX add model-specific functions below 
  for t in tables
    @[t] <<< query-dictionary[t]

  cb null

# vim:fdm=indent
