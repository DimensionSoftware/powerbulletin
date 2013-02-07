export post = (post) ->
  errors = []
  unless post.user_id
    errors.push 'user_id cannot be blank'
  unless post.forum_id
    errors.push 'forum_id cannot be blank'
  unless post.title
    errors.push 'title cannot be blank'
  unless post.body
    errors.push 'body cannot be blank'
  errors
