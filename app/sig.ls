# stacked signal handlers
#
# Example:
#
#   require! \./app/sig
#   sig.usr1 (-> console.log 1)
#   sig.usr1 (-> console.log 2)
#   sig.usr1 (-> console.log 3)
#
#   process.kill process.pid, \SIGUSR1
#   ## 1
#   ## 2
#   ## 3

export list = <[hup int quit ill trap abrt bus fpe kill usr1 segv usr2 pipe alrm term stkflt chld cont stop tstp ttin ttou urg xcpu xfsz vtalrm prof winch poll pwr sys]>

export handlers-for-signal = {}

export signal-handler = (name) ->
  !->
    handlers = handlers-for-signal[name]
    for h in handlers
      h!

set-handler = (name) ->
  signal-name = "SIG" + name.to-upper-case!
  (fn) ->
    if handlers = handlers-for-signal[name]
      handlers.push fn
    else
      process.on signal-name, signal-handler(name)
      handlers-for-signal[name] = [ fn ]

for s in list
  module.exports[s] = set-handler s
