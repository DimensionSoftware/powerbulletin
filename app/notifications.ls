require! {
  async
  \../shared/format
}

export send = (type, _from, _to, vars={}, cb=(->)) ->
  tmpl = templates[type]
  site = vars.site
  return cb new Error("no template for #type") unless tmpl
  return cb new Error("no site passed in") unless site
  err, aliases <- async.map _to, ((n, cb) -> console.log \n, n; db.aliases.select-one {site_id:site.id, name:n}, cb)
  if err then return cb err
  valid-aliases = aliases |> filter id

  # for each valid alias, send a notification
  actually-send = (a, cb) ->
    markup = tmpl { u: _from } <<< vars
    err, conversation <- db.conversations.between site.id, [ _from.id, a.user_id ]
    console.warn { err, conversation }
    if err then return cb err
    m =
      user_id         : _from.id
      conversation_id : conversation.id
      body            : markup
    console.warn \m, m
    db.messages.send m, cb
  async.each valid-aliases, actually-send, cb

export templates =
  mention: (vars) ->
    post = vars.post
    u = vars.u
    """
    @#{u.name} just mentioned you in [#{post.title}](#{post.uri}).
    """
