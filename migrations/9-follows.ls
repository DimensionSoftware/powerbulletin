
@up = (pg, cb) ->
  sql = '''
  CREATE TABLE follows (
    id          BIGSERIAL NOT NULL,
    site_id     BIGINT NOT NULL REFERENCES sites(id),
    user_id     BIGINT NOT NULL REFERENCES users(id),
    follow_id   BIGINT NOT NULL REFERENCES users(id),
    created     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated     TIMESTAMP,
    UNIQUE      (site_id, user_id, follow_id),
    PRIMARY KEY (id)
  );
  '''
  pg.query sql, [], cb

