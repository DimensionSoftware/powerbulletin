
require! {
  VoltClient        : '../node_modules/voltjs/lib/client'
  VoltConfiguration : '../node_modules/voltjs/lib/configuration'
  VoltProcedure     : '../node_modules/voltjs/lib/query'
}

# short, simple dsl so i don't go crazy and names match in volt and here
procs = {}
defp = (name, spec = []) ->
  procs[name] = new VoltProcedure name, spec
getp = -> procs[it]
getq = -> getp(it)?.get-query!

# we declare these procedures up here because we don't need to be creating a procedure every single time
# we run a query, the Query object on the other hand we have no choice because it contains
# parameters

# builtin procedures
defp 'DOCS.insert' [\string \string \string \tinyint \tinyint]
defp 'USERS.insert' [\bigint \string]

# custom procedures
defp 'AddPost' [\long \long \string \string] # id, userid, title, body
defp 'SelectUser' [\long] # id
defp \select_user [\long]
defp 'NextInSequence' [\string]
defp 'GetDoc' [\string \string] # type, key
defp 'PutDoc' [\string \string \string \long] #type, key, json, index_enabled

# it is assumed that init will have finished before any queries are exec'd
# then @client will be populated
export init = (host, cb = (->)) ->
  vconf = new VoltConfiguration {host}
  vcli = new VoltClient [vconf]

  vcli.connect (err, type, res) ~>
    if err then return cb(err)
    @client = vcli

    # make sure to catch all the errors...
    # create a little wrapper...
    # voltdb hides errors in its status field
    # i named this 'callq' since at the end of the day we are handing
    # a query object to the client
    @callq = (q, cb) ~>
      @client.call-procedure q, (err, type, res) ->
        if res.status is 1
          # table has the meat of the data, put it in the right spot ; )
          # XXX grabs first VoltTable, and assumes its the only thing of value
          #     eventually this might need to handle multiple volt tables
          #     being sent back?
          #     concat! clones the object without the extra voltdb annotation cruft
          vt = res.table
          cb(null, vt)
        else
          # propagate error the nodejs way
          cb(new Error(res.status-string))
    cb!

export callp = (pname, ...raw-args) ->
  params = raw-args.slice 0, -1
  cb = raw-args[raw-args.length - 1]
  if q = getq pname
    q.set-parameters params
    @callq q, cb
  else
    throw new Error "There is no procedure named '#{pname}'"
