
@up = (pg, cb) ->
  alters-sql = """
  ALTER TABLE domains ALTER config SET DEFAULT '{"facebookClientSecret":"checked","twitterConsumerSecret":"checked","googleConsumerSecret":"checked","style":".has-facebook{display:inline}.has-twitter{display:inline}.has-google{display:inline}.has-auth{display:block}"}';
  """
  pg.query alters-sql, [], cb
