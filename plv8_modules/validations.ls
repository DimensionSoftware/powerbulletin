require! {
  pv: './pure-validations'
}

export post = (post) ->
  # pure-validations are shared with client code
  errors = pv.post(post)

  authorize-transient = plv8.find_function \procs.authorize_transient

  [{site_id}] = plv8.execute('SELECT site_id FROM forums WHERE id=$1', [post.forum_id])

  plv8.elog WARNING, JSON.stringify(post)

  u-exists =
    if post.user_id
      !!plv8.execute('SELECT TRUE FROM users WHERE id=$1', [post.user_id])

  t-exists =
    if post.transient_owner
      authorize-transient(post.transient_owner, site_id)

  unless u-exists or t-exists
    errors.push 'Posting is not authorized'

  return errors

export censor = (post) ->
  errors = pv.censor(post)
  errors

