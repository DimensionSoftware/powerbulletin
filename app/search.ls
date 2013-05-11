require! {
  el: \./elastic
}
# randomize work interval so we make better use of event architecture
# # but only but a small amount
# work-interval = 1200 + (Math.floor (Math.random! * 300)) # in ms
#
# now = new Date
# cutoff = new Date(now - work-interval)
#
# # XXX: integrate actual searchopts into date range query
# err, res <- elc.search {query: {range: {created: {from: cutoff.to-ISO-string!, to: now.to-ISO-string!, include_upper: false}}}}; cl res
# cl res
#
#
#
# shared library for searching between socket.io and express routes
# can probably have other uses in future =D

# searchopts documented in default properties below (livescript-ism)
# returns something suitable for elastic
# WARNING: does not do any protection against injection so this should happen in the controller
parseopts = ({
  q = void
  stream = void
} = {}) ->

  query = {}
  filter = {}

  # modify query / filter here with series of conditions based on opts
  if q
    query.query_string =
      query: q

  if stream
    filter.range =
      created:
        from: stream.cutoff.to-ISO-string!
        to: stream.now.to-ISO-string!
        include_upper: false

  # cleanup so elastic doesn't freak if query / filter are empty
  rval = {}
  rval <<< {query} if Object.keys(query).length
  rval <<< {filter} if Object.keys(filter).length

  rval

# usage on repl:
#   s.search q: \mma, console.log
@search = (searchopts, cb) ->
  console.log parsed: JSON.stringify(parseopts(searchopts))
  elc = el.client # XXX: argh..... lol
  elc.search parseopts(searchopts), cb
