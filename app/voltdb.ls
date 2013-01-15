
require! {
  VoltClient        : '../node_modules/voltjs/lib/client'
  VoltConfiguration : '../node_modules/voltjs/lib/configuration'
  VoltProcedure     : '../node_modules/voltjs/lib/query'
}

# short, simple dsl so i don't go crazy and names match in volt and here
procs = {}
defp = (name, spec) ->
  procs[name] = new VoltProcedure name, spec
getp = -> procs[it]
getq = -> getp(it).get-query!

defp 'DOCS.insert' [\string \string \string \tinyint \tinyint]
defp 'USERS.insert' [\bigint \string]
defp 'select_doc_by_type_and_key' [\string \string]
defp 'SelectUsers' []

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
    # i named this 'callq' since at the end of the day we are handing
    # a query object to the client
    @callq = (q, cb) ~>
      @client.call-procedure q, (err, type, res) ->
        console.log {err, type, res}
        if res.status is 1
          # table has the meat of the data, put it in the right spot ; )
          # XXX grabs first VoltTable, and assumes its the only thing of value
          #     eventually this might need to handle multiple volt tables
          #     being sent back?
          #     concat! clones the object without the extra voltdb annotation cruft
          vt = res.table[0].concat!
          cb(null, vt)
        else
          # propagate error the nodejs way
          cb(new Error(res.status-string))
    cb!

# a misc doc is just a one-off document we wanna store and don't wanna index
# i.e. a blob for the homepage
export get-misc-doc = (key, cb) ->
  q = getq 'select_doc_by_type_and_key'
  q.set-parameters [\misc, key]

  err, res <- @callq q
  if err then return cb(err)

  cb null, JSON.parse(res.JSON)

#XXX: this needs to handle updates to, should that be pushed inside the procedure?
export put-misc-doc = (key, val, cb = (->)) ->
  json = JSON.stringify(val)
  q = getq 'DOCS.insert'
  q.set-parameters [key, \misc, json, 0, 0]
  @callq q, cb

export test-insert = (cb = (->)) ->
  q1 = getq 'USERS.insert'
  q1.set-parameters [1 \matt]
  q2 = getq 'USERS.insert'
  q2.set-parameters [2 \bob]
  @callq q1, (->)
  @callq q2, (->)
  cb!

export select-users = (cb = (->)) ->
  @callq getq('SelectUsers'), cb
