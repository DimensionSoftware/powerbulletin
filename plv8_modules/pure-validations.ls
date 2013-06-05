export post = (post) ->
  errors = []
  unless post.user_id xor post.transient_owner
    errors.push 'must specify a user_id or transient_owner'
  unless post.forum_id
    errors.push 'forum_id cannot be blank'
  unless post.title or post.parent_id
    errors.push 'must specify a title or parent_id'
  unless post.body
    errors.push 'body cannot be blank'
  errors

export censor = (c) ->
  errors = []
  unless c.user_id
    errors.push 'user_id cannot be blank'
  unless c.post_id
    errors.push 'post_id cannot be blank'
  unless c.reason
    errors.push 'reason cannot be blank'
  errors
