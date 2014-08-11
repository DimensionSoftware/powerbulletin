
@up = (pg, cb) ->
  google-consumer-key = '222545619172-n5eaojlnl2n4vcsvao3quq5v1i81j4ge.apps.googleusercontent.com'
  google-consumer-secret = 'E-Ih-2AdTQTNtjmh2LVUx2yt'
  twitter-consumer-key = 'RDUmY0fhaQni35X3xXVMQ'
  twitter-consumer-secret = 'uV5C6dMPyTvT0Xskt7thNsljzivGqejqZl8l1iSSY'

  err, r <- pg.query 'SELECT config FROM domains WHERE id = 1', []
  config = JSON.parse r.rows.0.config
  config.google-consumer-key = google-consumer-key
  config.google-consumer-secret = google-consumer-secret
  config.twitter-consumer-key = twitter-consumer-key
  config.twitter-consumer-secret = twitter-consumer-secret
  sql = """
  UPDATE domains SET config = $1 WHERE id = 1
  """
  pg.query sql, [JSON.stringify config], cb
