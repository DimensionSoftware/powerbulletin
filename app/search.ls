require! {
  el: \./elastic
}

const day-ms = 24h * 60m * 60s * 1000ms
const week-ms = day-ms * 7
const month-ms = day-ms * 30

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
  forum_id = void
  within = void
  stream = void
} = {}) ->
  query = {}
  filters = []
  facets =
    forum:
      terms:
        field: \forum_id

  # modify query / filter here with series of conditions based on opts
  if q
    query.query_string =
      query: q

  if forum_id
    filters.push {
      term: {forum_id}
    }

  if within
    now = new Date
    duration-ms =
      switch within
      | \day   => day-ms
      | \week  => week-ms
      | \month => month-ms

    filters.push {
      range:
        created:
          from: (new Date(now - duration-ms)).to-ISO-string!
    }

  if stream
    filters.push {
      range:
        created:
          from: stream.cutoff.to-ISO-string!
          to: stream.now.to-ISO-string!
          include_upper: false
    }

  # cleanup so elastic doesn't freak if query / filter are empty
  rval =
    highlight:
      fields:
        title: {}
        body: {}
      pre_tags: ['<span class="search-hit">']
      post_tags: ['</span>']

  rval <<< {query} if Object.keys(query).length
  rval <<< {filter: {and: filters}} if filters.length
  rval <<< {facets}

  rval

# usage on repl:
#   s.search q: \mma, console.log
@search = (searchopts, cb) ->
  elc = el.client # XXX: argh..... lol

  elc.search parseopts(searchopts), cb

