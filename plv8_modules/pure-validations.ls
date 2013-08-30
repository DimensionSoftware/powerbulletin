define = window?define or if plv8? then (-> it!) else require(\amdefine)
require, exports, module <- define

export post = @post = (post) ->
  errors = []
  unless post.user_id
    errors.push 'Must specify a user'
  unless post.forum_id
    errors.push 'Forum cannot be blank'
  unless post.title or post.parent_id
    errors.push 'Title your creation!'
  unless post.body
    errors.push 'Write something!'
  errors

export censor = @censor = (c) ->
  errors = []
  unless c.user_id
    errors.push 'User cannot be blank'
  unless c.post_id
    errors.push 'Post cannot be blank'
  unless c.reason
    errors.push 'Reason cannot be blank'
  errors

export subdomain = @subdomain = (subdomain) ->
  allowed-chars = /^[a-z0-9\-]+$/i

  errors = []
  unless subdomain.match allowed-chars
    errors.push 'Invalid Subdomain'
  errors

@
