
@up = (pg, cb) ->
  # site_id & user_id added for ease of look-up later
  sql = '''
    CREATE TABLE attachments (
      id              BIGSERIAL NOT NULL,
      csurf           varchar(64),
      filename        varchar(256),
      post_id         BIGINT NOT NULL references posts(id),
      site_id         BIGINT NOT NULL references sites(id),
      user_id         BIGINT NOT NULL references users(id),
      created         timestamp NOT NULL DEFAULT now(),
      UNIQUE          (csurf),
      PRIMARY         KEY (id)
    )
  '''
  err, r <- pg.query sql, [], cb
  if err then return cb err
