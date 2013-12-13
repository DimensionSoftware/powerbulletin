
@up = (pg, cb) ->
  sql = '''
  CREATE TABLE images (
    id          BIGSERIAL NOT NULL,
    post_id     BIGINT NOT NULL REFERENCES posts(id),
    thread_id   BIGINT NOT NULL REFERENCES posts(id),
    is_local    BOOLEAN NOT NULL DEFAULT false,
    url         VARCHAR(256) NOT NULL,
    PRIMARY KEY (id)
  );
  '''
  pg.query sql, [], cb

