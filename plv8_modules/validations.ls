require! {
  pv: './pure-validations'
}

export post = (post) ->
  # pure-validations are shared with client code
  errors = pv.post(post)
  # plv8.execute validations go here
  # they might add to errors array
  errors

export censor = (post) ->
  errors = pv.censor(post)
  errors

