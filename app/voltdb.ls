
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
defp \add_post2 [\long \long \string \string]
defp 'NextInSequence' [\string]
defp 'GetDoc' [\string \string] # type, key
defp 'PutDoc' [\string \string \string \long] #type, key, json, index_enabled

# if it returns null for err, then everything is groovy
# if it returns true for err, then you need to re-initialize connection
_t = @
init-health-check-loop = ->
  health-check = (cb) ~>
    _t.callp \select_user, 1, cb

  checker = ~>
    unhealthy <~ health-check
    if unhealthy
      _t.connect!
      console.warn 'voltdb connection unhealthy, reconnecting...'

  set-interval checker, 5000

# @client will be populated after calling this, (init must have been called)
export connect = (host = @host, cb = (->)) ->
  vconf = new VoltConfiguration {host: @host}
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

# it is assumed that init will have finished before any queries are exec'd (or connect is called)
# this also starts the health check loop
export init = (host, cb = (->)) ->
  @host = host
  err <- @connect(host)
  if err then return cb(err)

  # wait 10000ms to start health checking
  set-timeout init-health-check-loop, 10000

  cb!

export callp = (pname, ...raw-args) ->
  params = raw-args.slice 0, -1
  cb = raw-args[raw-args.length - 1]
  procedure-finished = false

  # check to see if procedure call timed out
  # if procedure did time out, then return error!
  timeout-checker = ~>
    unless procedure-finished
      if @callq
        @connect!
        return cb(new Error "voltdb procedure '#{pname}' timed out, reconnecting...")
      else
        throw new Error 'voltdb is not initialized (did you call init?)'

  if q = getq pname
    q.set-parameters params
    if @callq
      set-timeout timeout-checker, 3000 # the health check has 3000ms to complete, before timing out
      err, res <- @callq q
      procedure-finished := true # timeout-checker will not fire after setting this
      if err then return cb(err)
      cb null, res
    else
      throw new Error 'voltdb is not initialized (did you call init?)'
  else
    throw new Error "There is no procedure named '#{pname}'"

