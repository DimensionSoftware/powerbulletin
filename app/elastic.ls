require! elastical

export init = (cb = (->)) ->
  @client = new elastical.Client '127.0.0.1'
  cb!
