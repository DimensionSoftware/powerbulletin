
@up = (pg, cb) ->
  sql = '''
    COMMENT ON TABLE aliases IS 'represents membership of a user in a site; user info pertaining to a particular site';
    COMMENT ON COLUMN aliases.rights IS 'site-level rights for powerbulletin system';

    ALTER TABLE users ADD COLUMN rights JSON NOT NULL DEFAULT '{"super":0}';
    COMMENT ON COLUMN users.rights IS 'system-level rights for powerbulletin system';
  '''
  pg.query sql, [], cb
