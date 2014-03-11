require! {
  elastical
  superagent
}

export init = (cb = (->)) ->
  @client = new elastical.Client '127.0.0.1'
  try
    @configure!
    cb!
  catch
    # initial configuration is probably already complete
    cb!

# configure the index with the appropriate settings
# i.e. configure analyzers
# assumes client is initialized
export configure = (cb = (->)) ->
  settings =
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
  #mappings =
  #  _default_:
  #    properties:
  #      forum_title:
  #        type: \string
  #        index: \not_analyzed
  mappings =
    _default_:
      _timestamp: {+enabled, +store}

  err <- superagent.post('http://127.0.0.1:9200/pb').send({settings, mappings}).end(_)
  if err
    console.error \elastic, err?res?body
    return cb err

  cb!
