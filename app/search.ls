require! {
  el: \./elastic
  sh: \./shared-helpers
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
  site_id = void
  stream = void
  page = 1
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

  if site_id
    filters.push {
      term: {site_id}
    }

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
        _timestamp:
          gt: stream.cutoff.to-ISO-string!
          lte: stream.now.to-ISO-string!
    }

  # cleanup so elastic doesn't freak if query / filter are empty
  # XXX: this doesn't work yet, not sure why, needs some more hacking
  #rval =
  #  highlight:
  #    fields:
  #      title: {}
  #      body: {}
  #    pre_tags: ['<span class="search-hit">']
  #    post_tags: ['</span>']

  filtered = {}
  if Object.keys(query).length
    filtered <<< {query}
  else
    filtered <<< {query: {match_all: {}}}

  filtered <<< {filter: {and: filters}} if filters.length

  do ->
    #XXX: step assumed to be fixed at 10 for now
    step = 10
    from = (page - 1) * step
    now = new Date
    one-year-duration-ms = (365 * 24 * 60 * 60 * 1000)
    one-year-ago = now - one-year-duration-ms
    {
      query:
        custom_score:
          query: {filtered}
          # recency factor is weighted 99:1 to elastic score and then the
          # mean average is taken so we have a value in the range of 0..1
          # subtracting one-year-ago makes it so that only the last year
          # of recency counts...
          script: "(_score + (99 * ((doc.created.value - #one-year-ago) / #one-year-duration-ms))) / 100"
      from
      facets
    }


# usage on repl:
#   s.search q: \mma, console.log
@search = (searchopts, cb) ->
  elc = el.client # XXX: argh..... lol

  err, res, res2 <- elc.search parseopts(searchopts)
  if err then return cb err

  for h in res.hits
    sh.add-dates h._source

  cb null, res, res2


