
@up = (pg, cb) ->
  sql = '''
    CREATE TABLE messages_read (
      id              BIGSERIAL NOT NULL,
      message_id      BIGINT NOT NULL references messages(id),
      user_id         BIGINT NOT NULL references users(id),
      UNIQUE          (message_id, user_id),
      PRIMARY         KEY (id)
    );
  '''
  pg.query sql, [], cb
