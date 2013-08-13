require! {
  async
  pg
  debug
  \fs
  orm: \thin-orm
  postgres: \./postgres
}

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

# This is for queries that don't need to be stored procedures.
# Base the top-level key for the table name from the FROM clause of the SQL query.
query-dictionary =
  # db.users.all cb
  users:
    all: postgres.query 'SELECT * FROM users', [], _


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
