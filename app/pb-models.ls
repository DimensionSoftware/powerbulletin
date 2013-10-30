require! {
  async
  pg
  debug
  \fs
  orm: \thin-orm
  postgres: \./postgres
}

{filter, join, keys, values, sort-by} = require \prelude-ls

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

# Generate an upsert function for the given table name
# 
# @param  String    table   name of table
# @return Function          an upsert function for the table
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

# Generate a dlete function for the given table name
#
# @param  String    table   name of table
# @return Function          a delete function for the table
delete-fn = (table) ->
  (object, cb) ->
    postgres.query "DELETE FROM #table WHERE id = $1", [ object.id ], cb

# This is for queries that don't need to be stored procedures.
# Base the top-level key for the table name from the FROM clause of the SQL query.
query-dictionary =
  aliases:

    # Add aliases to a user
    #
    # @param Integer    user-id
    # @param Array      site-ids
    # @param Object     attrs
    # @param Function   cb
    add-to-user: (user-id, site-ids, attrs, cb) ->
      if not attrs.name
        cb new Error "attrs.name required!"

      do-insert = (site-id, cb) ->
        row =
          user_id : user-id
          site_id : site-id
          photo   : \/images/profile.jpg
        row <<< attrs
        [insert-sql, vals] = insert-statement \aliases, row
        postgres.query insert-sql, vals, cb

      async.each site-ids, do-insert, cb

  # db.users.all cb
  users:
    # used by SuperAdminUsers
    all: ({site_id, limit, offset}, cb) ->
      sql = """
      SELECT
        u.id, u.email, u.rights AS sys_rights,
        a.name, a.photo, a.rights AS site_rights, a.verified, a.created, a.site_id
      FROM users u
      JOIN aliases a ON a.user_id=u.id
      #{if site_id then 'WHERE a.site_id=$3' else ''}
      LIMIT $1 OFFSET $2
      """
      params =
        if site_id
          [limit, offset, site_id]
        else
          [limit, offset]

      err, users <- postgres.query sql, params
      if err then return cb err

      for u in users
        sys-r = JSON.parse delete u.sys_rights
        site-r = JSON.parse delete u.site_rights
        u.sys_admin = !! sys-r.super
        u.site_admin = !! site-r.super

      cb null, users

    all-count: ({site_id}, cb) ->
      sql = """
      SELECT COUNT(*)
      FROM users u
      JOIN aliases a ON a.user_id=u.id
      #{if site_id then 'WHERE a.site_id=$1' else ''}
      """
      params =
        if site_id
          [site_id]
        else
          []
      err, [{count}] <- postgres.query sql, params
      if err then return cb err
      cb null, count
    email-in-use: ({email}, cb) ->
      err, r <- postgres.query 'SELECT COUNT(*) AS c FROM users WHERE email = $1', [email]
      if err then return cb err
      cb null, !!r.0.c

    # Given an email, load a user.
    # If the user does not have an alias for the given site-id,
    # name, photo, rights, and config will be void
    by-email-and-site: (email, site-id, cb) ->
      user-sql = '''
      SELECT u.* FROM users u WHERE u.email = $1
      '''
      auths-sql = '''
      SELECT a.* FROM auths a WHERE a.user_id = $1
      '''
      alias-sql = '''
      SELECT a.* FROM aliases a WHERE a.site_id = $1 AND a.user_id = $2
      '''
      err, r <- postgres.query user-sql, [email]
      if err then return cb err
      if r.length is 0
        return cb null, null
      user = r.0
      err, auths <- postgres.query auths-sql, [user.id]
      if err then return cb err
      user.auths = fold ((a,b) -> a[b.type] = JSON.parse(b.profile); a), {}, auths
      err, r <- postgres.query alias-sql, [site-id, user.id]
      if err then return cb err

      # site-specific info to be mixed into this user
      if r.0
        _a = r.0
        alias =
          name    : _a.name
          photo   : _a.photo
          rights  : _a.rights
          config  : _a.config
          site_id : site-id
      else
        alias =
          name    : void
          photo   : void
          rights  : void
          config  : void
          site_id : site-id
      cb null, user <<< alias

  pages:
    upsert: upsert-fn \pages
    delete: delete-fn \pages

  posts:
    moderated: (forum-id, cb) ->
      postgres.query '''
      SELECT
        p.*,
        a.name AS user_name,
        a.photo AS user_photo
      FROM posts p
      JOIN forums f ON f.id=p.forum_id
      JOIN users u ON u.id=p.user_id
      JOIN aliases a ON a.user_id=u.id AND a.site_id=f.site_id
      JOIN moderations m ON m.post_id=p.id
      WHERE p.forum_id=$1
      ''', [forum-id], cb

  forums:
    upsert: upsert-fn \forums
    delete: delete-fn \forums

  sites:
    owned-by-user: (user-id, cb) ->
      # add user count
      sql = '''
      SELECT
        s.*,
        d.name AS domain,
        (SELECT COUNT(a.user_id) FROM aliases a WHERE a.site_id = s.id) AS user_count
      FROM sites s
      JOIN domains d ON d.site_id = s.id
      WHERE s.user_id = $1
      ORDER BY s.id, d.id
      '''
      err, r <- postgres.query sql, [user-id]
      if err then return cb err

      combine = (a, b) ->
        if not a[b.id]
          a[b.id] = b
          b.domains = [ b.domain ]
          delete b.domain
        else
          a[b.id].domains.push b.domain
        a

      sites = fold combine, {}, r
      |> values
      |> sort-by (.id)

      cb null, sites

  subscriptions:
    list-for-site: (site-id, cb) ->
      sql = '''
      SELECT * FROM subscriptions WHERE site_id = $1
      '''
      postgres.query sql, [site-id], cb


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
