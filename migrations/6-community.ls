
@up = (pg, cb) ->
  sql = '''
  UPDATE sites SET name = 'PowerBulletin Community' WHERE id = 4;

  UPDATE domains SET name = 'community.pb.com' WHERE id = 4;

  INSERT INTO domains (site_id, name) 
    SELECT 4, 'community.powerbulletin.com' WHERE NOT EXISTS
      (SELECT name FROM domains WHERE name = 'community.powerbulletin.com')
  '''
  pg.query sql, [], cb

