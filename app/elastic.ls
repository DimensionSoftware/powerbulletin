require! {
  elastical
  superagent
}

export init = (cb = (->)) ->
  @client = new elastical.Client '127.0.0.1'
  try
    @configure cb
  catch
    # initial configuration is probably already complete
    cb!

# configure the index with the appropriate settings
# i.e. configure analyzers
# assumes client is initialized
export configure = (cb = (->)) ->
  data =
    index:
      analysis:
        analyzer:
          default_index:
            tokenizer: \standard
            filter: [\lowercase, \pb_ngram]
          default_search:
            tokenizer: \standard
            filter: [\lowercase]
        filter:
          pb_ngram:
            type: \nGram
            min_gram: 2
            max_gram: 15

  err, res <- superagent.post('http://127.0.0.1:9200/pb').send(data).end
  if err then return cb err
  cb!
