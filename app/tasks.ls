export for-mutant =
  homepage:
    "menu"             : void # db.menu site.id, _
    "forums :forum-id" : void # db.forum forum-id, _
  forum:
    "menu"                  : void # db.menu res.vars.site.id, _
    "forum :forum-id"       : void # db.forum forum-id, _
    "forums :forum-id"      : void # db.forum-summary forum-id, 10, 5, _
    "top-threads :forum-id" : void # db.top-threads forum-id, \recent, _
  thread:
    "menu"                                    : void # db.menu site.id, _
    "sub-posts-tree :post-id :limit :offset"  : void # db.sub-posts-tree site.id, post.id, limit, offset, _
    "sub-posts-count :post-id"                : void # db.sub-posts-count post.id, _
    "top-threads :forum-id"                   : void # db.top-threads post.forum_id, \recent, _
    "forum :forum-id"                         : void # db.forum post.forum_id, _
  profile:
    "menu"                          : void # db.menu site.id, _
    "profile :user-id"              : void # db.usr usr, _
    "posts-by-user :user-id :page"  : void # db.posts-by-user usr, page, ppp, _
    "pages-count :user-id"          : void # db.posts-by-user-pages-count usr, ppp, _

export required-tasks = ([src,src-params], [dst,dst-params]) ->
  keys difference(expand-keys(src, src-params), expand-keys(dst, dst-params)) |> map (-> it.replace(/ .*$/, ''))

export difference = (a, b) ->
  { [k, v] for k, v of a when not b.has-own-property k  }

export expand-keys = (a, vars) ->
  { [expand-string(k, vars), v] for k, v of a }

export expand-string = (s, vars) ->
  s.replace /(:[\w-]+)/g, (m, p) -> vars[cc(p)]

export cc = (s) ->
  [first, ...rest] = s.split '-'
  first.replace(/^:/, '') + (rest |> map (-> it.char-at(0).to-upper-case! + it.slice(1)) |> join '')
