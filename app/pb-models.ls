require! {
  pg
  orm: \thin-orm
  postgres: \./postgres
}

export orm    = orm
export client = { connect: (cb) -> pg.connect postgres.conn-str, cb }
export driver = orm.create-driver \pg, { pg: client }
export schema = [
  [ \users,   <[id email photo created updated]> ]
  [ \aliases, <[user_id site_id name verify verified forgot rights created updated]> ]
  [ \sites,   <[id name config user_id created updated]> ]
]

export-model = ([t, cs]) ->
  orm.table(t).columns(cs)
  module.exports[t] = orm.create-client driver, t

each export-model, schema


## add model-specific functions below 

@sites.make-site-css = (cb) ->
  cb null, false

# vim:fdm=indent
