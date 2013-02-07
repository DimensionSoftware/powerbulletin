top-forums = (site-id) ->
  sql = '''
    SELECT * FROM forums
    WHERE parent_id IS NULL AND site_id=$1
    ORDER BY created DESC, id DESC
    '''
  plv8.execute sql, [site-id]

top-posts = (forum-id) ->
  sql = '''
    SELECT p.*, a.name user_name
    FROM posts p, aliases a
    WHERE a.user_id=p.user_id
      AND a.site_id=1
      AND p.parent_id IS NULL
      AND p.forum_id=$1
    ORDER BY created DESC, id DESC
    '''
  plv8.execute sql, [forum-id]
 
sub-posts = (parent-id) ->
  sql = '''
    SELECT p.*, a.name user_name
    FROM posts p, aliases a
    WHERE a.user_id=p.user_id
      AND a.site_id=1
      AND p.parent_id=$1
    ORDER BY created DESC, id DESC
  '''
  sub-posts = plv8.execute sql, [parent-id]
  
# recurses to build entire comment tree
sub-posts-tree = (parent-id) ->
  [p <<< {posts: sub-posts-tree(p.id)} for p in sub-posts(parent-id)]

# gets entire list of top posts and inlines all sub-posts to them
posts = (forum-id) ->
  [p <<< {posts: sub-posts-tree(p.id)} for p in top-posts(forum-id)]

export forums = (site-id) ->
  [f <<< {posts: posts(f.id)} for f in top-forums(site-id)]
