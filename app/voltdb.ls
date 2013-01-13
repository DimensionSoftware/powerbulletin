
require! {
  VoltClient        : '../node_modules/voltjs/lib/client'
  VoltConfiguration : '../node_modules/voltjs/lib/configuration'
  VoltProcedure     : '../node_modules/voltjs/lib/query'
}


insert-doc-proc = new VoltProcedure 'DOCS.insert' [\string \string \string \tinyint \tinyint]
insert-user-proc = new VoltProcedure 'USERS.insert' [\bigint \string]

# it is assumed that init will have finished before any queries are exec'd
# then @client will be populated
export init = (host, cb = (->)) ->
  vconf = new VoltConfiguration {host}
  vcli = new VoltClient [vconf]

  vcli.connect (err, type, res) ~>
    if err then return cb(err)
    console.log res.status
    console.log res.status-string
    @client = vcli

    # make sure to catch all the errors...
    # create a little wrapper...
    # voltdb hides errors in its status field
    @callp = (q, cb) ~>
      @client.call-procedure q, (err, type, res) ->
        if res.status is 1
          cb(err, type, res)
        else
          # propagate error the nodejs way
          cb(new Error(res.status-string), type, res)
    cb!

# a misc doc is just a one-off document we wanna store and don't wanna index
# i.e. a blob for the homepage
export insert-misc-doc = (key, val, cb = (->)) ->
  json = JSON.stringify(val)
  q = insert-doc-proc.get-query!
  q.set-parameters [key, \misc, json, 0, 0]
  @callp q, cb

export test-insert = (cb = ->) ->
  q = insert-user-proc.get-query!
  q.set-parameters [1 \matt]
  @callp q, cb

