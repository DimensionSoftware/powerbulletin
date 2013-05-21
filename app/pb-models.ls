require! {
  async
  pg
  \fs
  \mkdirp
  orm: \thin-orm
  postgres: \./postgres
}

export orm    = orm
export client = { connect: (cb) -> pg.connect postgres.conn-str, cb }
export driver = orm.create-driver \pg, { pg: client }
#export schema = [
#  [ \users,   <[id email photo created updated]> ]
#  [ \aliases, <[user_id site_id name verify verified forgot rights created updated]> ]
#  [ \sites,   <[id name config user_id created updated]> ]
#]

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
  WHERE table_catalog=$1 AND table_name=$2
  ORDER BY ordinal_position asc
  '''
  err, rows <- postgres.query sql, [dbname, tname]
  if err then return cb(err)
  cb null, rows.map (.column_name)

# assumed postgres is initialized
export init = (cb) ->
  err, tables <~ get-tables \pb, _
  if err then return cb(err)
  err, colgroups <~ async.map tables, (get-cols \pb, _, _)
  if err then return cb(err)
  schema = zip tables, colgroups

  # query db and create export-model
  each export-model, schema

  ## add model-specific functions below 
  @sites.save-stylus = (domain, stylus, cb=(->)) ->
    base = "public/domains/#domain"
    err <- mkdirp base
    if err then console.error \mkdirp.rename, err; return cb err # guard
    err <- fs.write-file "#base/site.css" stylus
    if err then console.error \fs.write-file, err; return cb err # "
    cb!

  cb null

# vim:fdm=indent
