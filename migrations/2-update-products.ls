
@up = (pg, cb) ->
  sql = '''
    UPDATE products SET config='{"features":["Embed analytic scripts"]}' WHERE id='analytics';
    UPDATE products SET description='Private Community', config='{"features":["Block search engines","Low public profile"]}' WHERE id='private';
    UPDATE products SET description='Custom Domain', config='{"features":["Add your domain"]}' WHERE id='custom_domain';
  '''
  pg.query sql, [], cb
