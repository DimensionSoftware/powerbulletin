
require! {
  VoltClient        : '../node_modules/voltjs/lib/client'
  VoltConfiguration : '../node_modules/voltjs/lib/configuration'
  VoltProcedure     : '../node_modules/voltjs/lib/query'
}

new-user-proc = new VoltProcedure 'USERS.insert' [\bigint \string]

# it is assumed that init will have finished before any queries are exec'd
# then @client will be populated
export init = (host, cb) ->
  vconf = new VoltConfiguration {host}
  vcli = new VoltClient [vconf]

  vcli.connect (err) ~>
    if err then return cb(err)
    @client = vcli
    cb!

export test-insert = (cb) ->
  q = new-user-proc.get-query!
  q.set-parameters [1 \matt]
  @client.call-procedure q, cb

