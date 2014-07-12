define = window?define or if plv8? then (-> it!) else require(\amdefine)
require, exports, module <- define

export post = @post = (post) ->
  errors = []
  unless post.user_id
    errors.push 'Must Specify A User'
  unless post.forum_id
    errors.push 'Forum Cannot Be Blank'
  unless post.title or post.parent_id
    errors.push 'Title Your Creation!'
  unless post.body
    errors.push 'Write Something!'
  errors

export censor = @censor = (c) ->
  errors = []
  unless c.user_id
    errors.push 'User Cannot Be Blank'
  unless c.post_id
    errors.push 'Post Cannot Be Blank'
  unless c.reason
    errors.push 'Reason Cannot Be Blank'
  errors

export subdomain = @subdomain = (subdomain) ->
  allowed-chars = /^[a-z0-9\-]+$/i

  errors = []
  unless subdomain.match allowed-chars
    errors.push 'Invalid Subdomain'
  errors

@
