require! LiveScript

module.exports = (bundle) ->
  bundle.register '.ls', (body, file) ->
    try
      js = LiveScript.compile body, filename: file
    catch error
      bundle.emit 'syntaxError', error
    
    return js