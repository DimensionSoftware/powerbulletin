
@up = (pg, cb) ->
  sql = '''
  CREATE TABLE thread_subscriptions (
    id          BIGSERIAL NOT NULL,
    site_id     BIGINT NOT NULL REFERENCES sites(id),
    user_id     BIGINT NOT NULL REFERENCES users(id),
    thread_id   BIGINT NOT NULL REFERENCES posts(id),
    UNIQUE      (site_id, user_id, thread_id),
    PRIMARY KEY (id)
  );
  '''
  pg.query sql, [], cb


