require! {
  furl: './forum-urls'
}

export for-mutant =
  forum:
    "menu"                  : 1 # db.menu res.vars.site.id, _
    "forum :forum-id"       : 1 # db.forum forum-id, _
    "forums :forum-id"      : 1 # db.forum-summary forum-id, 10, 5, _
    "top-threads :forum-id" : 1 # db.top-threads forum-id, \recent, _
  thread:
    "menu"                                    : 1 # db.menu site.id, _
    "sub-posts-tree :post-id :limit :offset"  : 1 # db.sub-posts-tree site.id, post.id, limit, offset, _
    "sub-posts-count :post-id"                : 1 # db.sub-posts-count post.id, _
    "top-threads :forum-id"                   : 1 # db.top-threads post.forum_id, \recent, _
    "forum :forum-id"                         : 1 # db.forum post.forum_id, _

export required-tasks = ([src,src-vars], [dst,dst-vars]) ->
  keys difference(expand-keys(src, src-vars), expand-keys(dst, dst-vars)) |> map (-> it.replace(/ .*$/, ''))

export difference = (a, b) ->
  { [k, v] for k, v of a when not b.has-own-property k  }

export pick = (a, keepers) ->
  { [k, v] for k, v of a when k in keepers }

export expand-keys = (a, vars) ->
  { [expand-string(k, vars), v] for k, v of a }

export expand-string = (s, vars) ->
  s.replace /(:[\w-]+)/g, (m, p) -> vars[cc(p)]

export cc = (s) ->
  [first, ...rest] = s.split '-'
  first.replace(/^:/, '') + (rest |> map (-> it.char-at(0).to-upper-case! + it.slice(1)) |> join '')

# Give recommendations on how to reduce work.
#
# @param String mutant    current mutant
# @param Object req       current request
# @returns Object
#   @param Array keep
#   @param Array remove
#export recommendation = (mutant, req) ->
export recommendation = (path, last-path) ->
  meta      = furl.parse path
  last-meta = furl.parse last-path

  simplify = (t) ->
    if t.match /^thread/ then \thread else t

  mutant      = simplify meta.type
  last-mutant = simplify last-meta.type

  default-recommendation = { remove: <[menu]> }
  #console.warn "---------------------------------------------------------------"
  #console.warn \meta, meta
  #console.warn \last-meta, last-meta
  switch mutant
  | \forum =>
    meta-vars =
      forum-id : 1
    last-meta-vars =
      forum-id : if meta.forum-uri is last-meta.forum-uri then 1 else 2
    if last-mutant is \thread
      last-meta-vars.post-id = 1
      last-meta-vars.limit   = 10
      last-meta-vars.offset  = 0
    src = for-mutant[mutant]
    dst = for-mutant[last-mutant]
    console.warn [mutant, meta-vars, meta], [last-mutant, last-meta-vars, last-meta]
    keep = required-tasks [src,meta-vars], [dst,last-meta-vars]
    { keep }
  | \thread =>
    meta-vars =
      forum-id : 1
      post-id  : 1
      limit    : 10
      offset   : ((meta.page || 1) - 1) * 10
    last-meta-vars =
      forum-id : if meta.forum-uri is last-meta.forum-uri then 1 else 2
    if last-mutant is \thread
      last-meta-vars.post-id = if meta.thread-uri is last-meta.thread-uri then 1 else 2
      last-meta-vars.limit  = 10
      last-meta-vars.offset = ((last-meta.page || 1) - 1) * 10
    src = for-mutant[mutant]
    dst = for-mutant[last-mutant]
    #console.warn [mutant, meta-vars, meta], [last-mutant, last-meta-vars, last-meta]
    keep = required-tasks [src,meta-vars], [dst,last-meta-vars]
    { keep }
  | otherwise => default-recommendation
