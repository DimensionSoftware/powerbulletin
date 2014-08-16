
@up = (pg, cb) ->
  api-keys =
    prod:
      linkedin-consumer-key: \75g60ung9wpn26
      linkedin-consumer-secret: \LLSssJQMEsqbYgQJ
    dev:
      linkedin-consumer-key: \75b20ct4tydipr
      linkedin-consumer-secret: \J0n6LPM3jVL7p4xG

  err, r <- pg.query 'SELECT config FROM domains WHERE id = 1', []
  config = JSON.parse r.rows.0.config
  config.linkedin-consumer-key = api-keys.dev.linkedin-consumer-key
  config.linkedin-consumer-secret = api-keys.dev.linkedin-consumer-secret
  delete config.google-consumer-id # +clean up a previous mistake
  sql = """
  UPDATE domains SET config = $1 WHERE id = 1
  """
  <- pg.query sql, [JSON.stringify config]

  err, r <- pg.query 'SELECT config FROM domains WHERE id = 13', []
  config = JSON.parse r.rows.0.config
  config.linkedin-consumer-key = api-keys.prod.linkedin-consumer-key
  config.linkedin-consumer-secret = api-keys.prod.linkedin-consumer-secret
  sql = """
  UPDATE domains SET config = $1 WHERE id = 13
  """
  pg.query sql, [JSON.stringify config], cb

