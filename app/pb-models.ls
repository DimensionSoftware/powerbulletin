require! {
  async
  pg
  debug
  stylus
  mkdirp
  \fs
  postgres: \./postgres
}

{filter, join, keys, values, sort-by} = require \prelude-ls

const base-css = \public/sites

# Generate a function that takes another function and transforms its first parameter
# according to the rules in serializers
#
# @param  Function  fn              function to wrap
# @param  Object    serializers
# @return Function                  wrapped function
serialized-fn = (fn, serializers) ->
  (object, ...rest) ->
    for k,sz of serializers
      if object?[k]
        object[k] = sz object[k]
    fn object, ...rest

# Generate a function that wraps an existing functions cb and deserializes its results
deserialized-fn = (fn, deserializers) ->
  (object, ...rest, cb) ->
    fn object, ...rest, (err, r) ->
      return cb err if err
      if r?length
        new-r = for item in r
          for k,sz of deserializers
            if item?[k]
              item[k] = deserializers[k] item[k]
          item
        cb null, new-r
      else
        item = r
        for k,dsz of deserializers
          if item?[k]
            item[k] = dsz item[k]
        cb null, item

where-x = (criteria, n=1) ->
  where-sql = "WHERE " + (keys criteria
    |> zip [n to n+100]
    |> map (-> "#{it.1} = $#{it.0}")
    |> join " AND ")
  where-vals = values criteria
  where-sql = "" if where-sql is "WHERE "
  [where-sql, where-vals]

select-statement = (table, wh) ->
  if wh is null
    wh-ere  = "WHERE id = $1"
    wh-vals = [obj.id]
  else
    wh-ere  = wh.0
    wh-vals = wh.1
  return ["SELECT * FROM #table #wh-ere", wh-vals]

insert-statement = (table, obj) ->
  columns   = keys obj
  value-set = [ "$#{i+1}" for k,i in columns ].join ', '
  vals      = values obj
  return ["INSERT INTO #table (#columns) VALUES (#value-set) RETURNING *", vals]

conditional-insert-statement = (table, obj, condition) ->
  columns   = keys obj
  value-set = [ "$#{i+1}" for k,i in columns ].join ', '
  vals      = values obj
  sql       = """
  INSERT INTO #table (#columns)
    SELECT #value-set WHERE NOT EXISTS
      (SELECT * FROM #table WHERE #condition)
  """
  return [sql, vals]

update-statement = (table, obj, wh) ->
  unless wh
    wh-ere  = "WHERE id = $1"
    wh-vals = [obj.id]
  else
    wh-ere  = wh.0
    wh-vals = wh.1
  ks        = keys obj |> filter (-> it isnt \id)
  obj-vals  = [ obj[k] for k in ks ]
  value-set = [ "#k = $#{i + (wh-vals.length+1)}" for k,i in ks].join ', '
  vals      = [...wh-vals, ...obj-vals]
  return ["UPDATE #table SET #value-set #wh-ere RETURNING *", vals]

select1-fn = (table) ->
  (criteria, cb) ->
    [sql, vals] = select-statement table, where-x(criteria)
    sql1 = "#sql LIMIT 1"
    postgres.query sql1, vals, (err, r) ->
      cb err, r?0

selectx-fn = (table) ->
  (criteria, cb) ->
    [sql, vals] = select-statement table, where-x(criteria)
    postgres.query sql, vals, cb

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

# Generate an update function for the given table name that updates one row
#
# @param  String    table   name of table
# @param  Function  wh-fn   (optional) function that generates a where clause from an object
# @return Function          an update function for the table
update1-fn = (table, wh-fn=(->null)) ->
  (object, cb) ->
    [update-sql, vals] = update-statement table, object, wh-fn(object)
    postgres.query update-sql, vals, cb

# Generate an update function for the given table name that updates based on criteria passed to it
#
# @param  String    table   name of table
# @return Function          an update function for the table
updatex-fn = (table) ->
  (object, criteria, cb) ->
    [update-sql, vals] = update-statement table, object, where-x(criteria)
    postgres.query update-sql, vals, cb

# Generate a delete function for the given table name
#
# @param  String    table   name of table
# @return Function          a delete function for the table
delete-fn = (table) ->
  (object, cb) ->
    postgres.query "DELETE FROM #table WHERE id = $1", [ object.id ], cb

# Generate a WHERE clause to uniquely identify a row in the aliases table
_alias-where = (obj) ->
  throw new Error("need user_id and site_id") if (not obj.user_id and not obj.site_id);
  ["WHERE user_id = $1 AND site_id = $2", [obj.user_id, obj.site_id]]

_alias-serializers =
  rights: JSON.stringify
  config: JSON.stringify

_alias-deserializers =
  rights: JSON.parse
  config: JSON.parse

# Helper function for generating thread summaries by site and/or forum
#
# @param  Number    site-id
# @param  Number    forum-id
# @param  String    sort      \popular or \recent
# @param  Number    limit     max number of items desired in result set
# @param  Function  cb
thread-summary = (site-id, forum-id, sort, limit, cb) ->
  sort-criteria = switch sort
  | \popular  => "(SELECT (SUM(views) + COUNT(*)*2) FROM posts WHERE thread_id=p.thread_id) DESC, last_post_created DESC"
  | otherwise => "last_post_created DESC" # aka recent

  site-forum = if forum-id
    { clause: "f.site_id = $1 AND p.forum_id = $2", args: [ site-id, forum-id ] }
  else
    { clause: "f.site_id = $1", args: [ site-id ] }

  sql = """
  SELECT p.id,
         f.site_id,
         p.forum_id,
         p.title,
         p.views,
         p.created,
         p.user_id,
         p.media_url,
         a.name         AS user_name,
         a.photo        AS user_photo,
         last.id        AS last_post_id,
         last.user_id   AS last_post_user_id,
         last.name      AS last_post_name,
         last.html      AS last_html,
         last.created   AS last_post_created
    FROM posts p
    JOIN forums  f ON p.forum_id = f.id
    JOIN aliases a ON (p.user_id = a.user_id AND f.site_id = a.site_id)
    JOIN (SELECT p2.id, p2.user_id, a2.name, p2.html, p2.thread_id, p2.created
            FROM posts   p2
            JOIN forums  f2 ON p2.forum_id = f2.id
            JOIN aliases a2 ON (p2.user_id = a2.user_id AND f2.site_id = a2.site_id)
           WHERE p2.id IN (SELECT MAX(id) FROM posts GROUP BY thread_id)
             AND  a2.site_id = f2.site_id
         ) last ON last.thread_id = p.id
   WHERE a.site_id = f.site_id
     AND p.parent_id is NULL AND #{site-forum.clause}
   ORDER BY #sort-criteria
   LIMIT #limit
  """
  err, r <- postgres.query sql, site-forum.args
  if err then return cb err

  add-participants = (thread, cb) ->
    err, participants <- db.aliases.participants-for-thread thread.id
    if err then return cb err
    thread.participants = participants
    cb null, thread

  add-images = (thread, cb) ->
    err, images <- db.images.select thread_id: thread.id
    if err then return cb err
    thread.images = images
    cb null, thread

  add-multi = (thread, cb) ->
    err, t1 <- add-participants thread
    if err then return cb err
    add-images t1, cb

  async.map r, add-multi, cb

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
        uid = parse-int user-id
        sid = parse-int site-id
        [insert-sql, vals] = conditional-insert-statement \aliases, row, "user_id = #uid AND site_id = #sid"
        #console.log insert-sql, vals
        postgres.query insert-sql, vals, cb

      async.each site-ids, do-insert, cb

    most-recent-for-user: (user-id, cb) ->
      sql = '''
      SELECT * FROM aliases WHERE user_id = $1 ORDER BY created DESC LIMIT 1
      '''
      err, r <- postgres.query sql, [user-id]
      if err then return cb err
      cb null, r.0

    select-one : deserialized-fn (select1-fn \aliases), _alias-deserializers
    select     : deserialized-fn (selectx-fn \aliases), _alias-deserializers
    update-one : deserialized-fn (serialized-fn (update1-fn \aliases, _alias-where), _alias-serializers), _alias-deserializers
    update     : deserialized-fn (serialized-fn (updatex-fn \aliases), _alias-serializers), _alias-deserializers

    update-last-activity-for-user: (user, cb) ->
      id = user.id or user.user_id
      if not id then return cb null
      @update { last_activity: (new Date).to-ISO-string! }, { user_id: id, site_id: user.site_id }, cb

    participants-for-thread: (thread-id, cb) ->
      sql = '''
      SELECT p.user_id, a.name, a.photo, count(p.user_id) AS count
        FROM posts p
        JOIN forums f ON p.forum_id = f.id
        JOIN aliases a ON (a.site_id = f.site_id AND a.user_id = p.user_id)
       WHERE p.thread_id = $1
       GROUP BY p.user_id, name, photo
       ORDER BY count DESC
      '''
      postgres.query sql, [thread-id], cb

  # db.users.all cb
  users:
    # used by SuperAdminUsers
    all: ({site_id, q, limit, offset}, cb) ->
      pdollars = ['$' + i for i in [3 to 5]]
      where-clauses = []
      where-args = []

      maybe-add-clause = (args, clause-fns) ->
        if args.length and args.0
          # an array with length > 1 means combine with OR
          where-clauses.push "(#{[fn(pdollars.shift!) for fn in clause-fns].join(' OR ')})"
          where-args := where-args ++ args

      console.log \E
      maybe-add-clause [site_id], [-> "a.site_id = #it"]
      maybe-add-clause [q, q], [
        * -> "a.name @@ to_tsquery(#it)"
        * -> "u.email @@ to_tsquery(#it)"
      ]

      where-clause =
        if where-clauses.length
          'WHERE ' + where-clauses.join ' AND '
        else
          ''

      sql = """
      SELECT
        u.id, u.email, u.rights AS sys_rights,
        a.name, a.photo, a.rights AS rights, a.verified, a.created, a.site_id
      FROM users u
      JOIN aliases a ON a.user_id=u.id
      #where-clause
      LIMIT $1 OFFSET $2
      """
      console.log \SQL, "\n" + sql + "\n"
      params = [limit, offset] ++ where-args

      err, users <- postgres.query sql, params
      if err then return cb err

      for u in users
        sys-r = JSON.parse delete u.sys_rights
        site-r = JSON.parse delete u.rights
        u.sys_admin = !! sys-r.super
        u.site_admin = !! site-r.super

      cb null, users

    all-count: ({site_id, q}, cb) ->
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
      SELECT u.*, u.rights AS sys_rights FROM users u WHERE u.email = $1
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
      user.sys_rights = JSON.parse user.sys_rights
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
          rights  : JSON.parse _a.rights
          config  : JSON.parse _a.config
          site_id : site-id
      else
        alias =
          name    : void
          photo   : void
          rights  : void
          config  : void
          site_id : site-id
      cb null, user <<< alias

  auths: {}

  pages: {}

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

    upsert: upsert-fn \posts

    toggle-sticky: (id, cb) ->
      sql = '''
      UPDATE posts SET is_sticky = (NOT is_sticky) WHERE id = $1 RETURNING *
      '''
      postgres.query sql, [id], cb

    toggle-locked: (id, cb) ->
      sql = '''
      UPDATE posts SET is_locked = (NOT is_sticky) WHERE id = $1 RETURNING *
      '''
      postgres.query sql, [id], cb

  products: {}

  forums:
    # new forum summary
    summary: (site-id, forum-id, sort, limit, cb) ->
      thread-summary(site-id, forum-id, sort, limit, cb)

  sites:
    user-is-member-of: (user-id, cb) ->
      # every site user has an alias to
      sql = '''
      SELECT a.photo, a.name, d.site_id, d.name AS domain
      FROM aliases a
      JOIN domains d ON a.site_id = d.site_id
      WHERE user_id = $1
      ORDER BY d.id
      '''
      err, r <- postgres.query sql, [user-id]
      if err then return cb err
      cb null, r

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

    # save css to disk for site
    save-style: (site, cb) ->
      cb "no site.id"             if not site?id
      cb "no site.config.style"   if not site?config?style
      css-dir  = "#base-css/#{site.id}"
      err <- mkdirp css-dir
      if err then return cb err
      (err, css) <- stylus.render site.config.style, {compress:true}
      if err then return cb {success:false, msg:'CSS must be valid!'}
      fs.write-file "#css-dir/master.css" css, cb

    summary: (site-id, sort, limit, cb) ->
      thread-summary(site-id, null, sort, limit, cb)

  subscriptions:
    list-for-site: (site-id, cb) ->
      sql = '''
      SELECT * FROM subscriptions WHERE site_id = $1
      '''
      postgres.query sql, [site-id], cb

    select-one: select1-fn \subscriptions

  conversations:
    # returns a conversation object for the site and list of users, creating one if neeeded
    between: (site-id, users, cb) ->
      joins-sql = (n) ->
        [ "JOIN users_conversations uc#i ON uc#i.conversation_id = c.id" for i in [ 1 to n ] ].join "\n       "

      where-sql = (n) ->
        user-id-sql = [ "uc#i.user_id = $#i" for i in [1 to n] ]. join " AND "
        c-sql = "AND (SELECT COUNT(*) FROM users_conversations WHERE conversation_id = c.id) = #n"
        """
        #user-id-sql
               #c-sql
        """

      sql = """
      SELECT c.id,
             c.site_id,
             c.created,
             c.updated
        FROM conversations c
             #{joins-sql users.length}
       WHERE #{where-sql users.length}
             AND c.site_id = $#{users.length + 1}
      """
      #console.log sql
      err, r <~ postgres.query sql, [...users, site-id]
      if err then return cb err
      if r.length then return cb null, r.0

      # first time chatting together on this site
      insert-ppl-sql = (n) ->
        ["i#i AS (INSERT INTO users_conversations (user_id, conversation_id) SELECT $#{i+1}, id FROM c)" for i in [1 to n]].join ",\n  "
      new-sql = """
      WITH 
        c AS (INSERT INTO conversations (site_id) VALUES ($1) RETURNING *),
        #{insert-ppl-sql users.length}
        SELECT * FROM c;
      """
      #console.log new-sql
      err, r <~ postgres.query new-sql, [site-id, ...users]
      if err then return cb err
      return cb null, r.0

    # list of aliases for a given c-id
    participants: deserialized-fn ((c-id, cb) ->
      sql = '''
      SELECT a.user_id,
             a.site_id,
             a.name,
             a.photo,
             a.rights,
             a.config
        FROM aliases a
             JOIN conversations c ON c.site_id = a.site_id
             JOIN users_conversations uc ON (uc.user_id = a.user_id AND uc.conversation_id = c.id)
       WHERE c.id = $1
      '''
      postgres.query sql, [c-id], cb), rights: JSON.parse, config: JSON.parse

    # past conversations by site-id and user-id
    past: (site-id, user-id, cb) ->
      sql = '''
      SELECT c.id
        FROM conversations c
             JOIN users_conversations uc ON c.id = uc.conversation_id
       WHERE c.site_id = $1
             AND uc.user_id = $2
      '''
      # TODO - ORDER BY MAX(m.created) DESC ?
      # TODO - unwrap the object, just the ids
      postgres.query sql, [site-id, user-id], cb

    # grab a conversation + related info
    by-id: (id, cb) ->
      err, c <~ @select-one { id }
      if err then return cb err
      err, c.participants <~ @participants id
      if err then return cb err
      # TODO - also grab last few messages?
      cb err, c

    # unread message counts grouped by conversation
    unread-summary-by-user: (site-id, user-id, cb) ->
      sql = '''
      SELECT c.id,
             COUNT(m.id) - COUNT(mr.id) AS unread
        FROM conversations c
             JOIN messages m               ON c.id = m.conversation_id
             JOIN users_conversations uc   ON c.id = uc.conversation_id
             LEFT JOIN messages_read mr    ON (m.id = mr.message_id AND uc.user_id = mr.user_id)
       WHERE c.site_id = $1 AND uc.user_id = $2
       GROUP BY c.id
      '''
      # TODO - ORDER BY MAX(m.created) DESC ?
      # TODO - expose this data to the client side
      postgres.query sql, [site-id, user-id], cb

  messages:
    # mark a message as read
    mark-read: (id, user-id, cb) ->
      db.messages_read.upsert { message_id: id, user_id: user-id }, cb

serializers-for =
  json: JSON.stringify

deserializers-for =
  json: JSON.parse

export serializers = (cs) ->
  { [attribute, serializers-for[type]] for attribute, type of cs when serializers-for[type] }

export deserializers = (cs) ->
  { [attribute, deserializers-for[type]] for attribute, type of cs when deserializers-for[type] }

export-model = ([t, cs]) ->
  fns = if cs?id
    #console.log \model, t, cs
    {
      attrs      : cs
      select-one : (deserialized-fn (serialized-fn (select1-fn t), (serializers cs)), (deserializers cs))
      select     : (deserialized-fn (serialized-fn (selectx-fn t), (serializers cs)), (deserializers cs))
      update-one : (deserialized-fn (serialized-fn (update1-fn t), (serializers cs)), (deserializers cs))
      update     : (deserialized-fn (serialized-fn (updatex-fn t), (serializers cs)), (deserializers cs))
      upsert     : (deserialized-fn (serialized-fn (upsert-fn t), (serializers cs)), (deserializers cs))
      delete     : (serialized-fn (upsert-fn t), (serializers cs))
    }
  else
    #console.error \no-model, t
    { attrs : cs }
  module.exports[t] = fns

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
  SELECT ordinal_position, column_name, udt_name
  FROM information_schema.columns
  WHERE table_catalog=$1 AND table_name=$2 AND table_schema='public'
  ORDER BY ordinal_position asc
  '''
  err, rows <- postgres.query sql, [dbname, tname]
  if err then return cb(err)
  schema = { [o.column_name, o.udt_name] for o in rows }
  cb null, schema


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
