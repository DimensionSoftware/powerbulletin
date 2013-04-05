require! {
  fsm: './fsm'
}

#
# making sense of our forum urls
#

# /forum                                forum
# /forum/sub-forum                      forum
# /forum/sub-forum/sub-sub-forum        forum
# /forum/new                            new-thread
# /forum/t/thread                       thread (with implicit page 1)
# /forum/t/thread/2345                  thread-permalink (permalink into subtree)
# /forum/t/thread/edit/2345             edit-post
# /forum/t/thread/page/1                thread (with explicit page)
#

/*
states =
  * \initial
  * \forum
  * \new-thread
  * \-thread-marker
  * \thread
  * \thread-page
  * \-page-marker
  * \thread-permalink
  * \-permalink-page-marker
  * \thread-permalink-page
  * \-edit-marker
  * \edit
  * \error

inputs =
  * \string
  * \number
  * \new
  * \edit
  * \t
  * \page
*/

export type-of-part = (i) ->
  switch i
  | \page     => \page
  | \t        => \t
  | \edit     => \edit
  | \new      => \new
  | otherwise =>
    if i.match /^\d+$/ then \number else \string

export machine =
  initial:
    string : \forum
    number : \forum
    new    : \forum
    edit   : \forum
    t      : \forum
    page   : \forum
  forum:
    string : \forum
    number : \forum
    new    : \new-thread
    edit   : \forum
    t      : \-thread-marker
    page   : \forum
  'new-thread':
    string : \error
    number : \error
    new    : \error
    edit   : \error
    t      : \error
    page   : \error
  '-thread-marker':
    string : \thread
    number : \thread
    new    : \thread
    edit   : \thread
    t      : \thread
    page   : \thread
  thread:
    string : \thread-permalink
    number : \thread-permalink
    new    : \error
    edit   : \-edit-marker
    t      : \error
    page   : \-page-marker
  'thread-permalink':
    string : \error
    number : \error
    new    : \error
    edit   : \-edit-marker
    t      : \error
    page   : \-permalink-page-marker
  '-edit-marker':
    string : \error
    number : \edit
    new    : \error
    edit   : \error
    t      : \error
    page   : \error
  edit:
    string : \error
    number : \error
    new    : \error
    edit   : \error
    t      : \error
    page   : \error
  '-permalink-page-marker':
    string : \error
    number : \thread-permalink-page
    new    : \error
    edit   : \error
    t      : \error
    page   : \error
  'thread-permalink-page':
    string : \error
    number : \error
    new    : \error
    edit   : \error
    t      : \error
    page   : \error
  '-page-marker':
    string : \error
    number : \thread-page
    new    : \error
    edit   : \error
    t      : \error
    page   : \error
  'thread-page':
    string : \error
    number : \error
    new    : \error
    edit   : \error
    t      : \error
    page   : \error
  error:
    string : \error
    number : \error
    new    : \error
    edit   : \error
    t      : \error
    page   : \error


# Given a URL path, return the type of forum url and the associated metadata
# @param String path
# @returns Object info about the forum url
export parse = (path) ->
  parts  = path.split '/' |> reject (-> it is '')
  inputs = map type-of-part, parts
  type   = fsm.new-state machine, \initial, ...inputs
  meta   = switch type
  | \initial               => { incomplete: true }
  | \forum                 => { forum-uri: "/#{parts.join '/'}" }
  | \new-thread            => { forum-uri: "/#{parts[0 til parts.length - 1].join '/'}" }
  | \thread                => { thread-uri: "/#{parts.join '/'}" }
  | \thread-page           =>
    [ uri-parts, [page, n] ] = split-at parts.length - 2, parts
    { thread-uri: "/#{uri-parts.join '/'}", page: parseInt n }
  | \thread-permalink      =>
    { thread-uri: "/#{parts.join '/'}", slug: parts[*-1] }
  | \thread-permalink-page =>
    [ uri-parts, [page, n] ] = split-at parts.length - 2, parts
    { thread-uri: "/#{uri-parts.join '/'}", page: parseInt n }
  | \edit                  =>
    [ uri-parts, [edit, id] ] = split-at parts.length - 2, parts
    { thread-uri: "/#{uri-parts.join '/'}", id: parseInt id }
  | otherwise              => { incomplete: true }
  { type, parts, path: "/#{parts.join '/'}" } <<< meta


/*
Try these in the REPL.

furl.parse '/otherground-forum'
furl.parse '/otherground-forum/supportground'
furl.parse '/otherground-forum/new'                                                 # we can identify the new thread marker
furl.parse '/otherground-forum/supportground/t/new'                                 # threads can be called "new"
furl.parse '/otherground-forum/supportground/t/edit'                                # threads can be called "edit"
furl.parse '/otherground-forum/supportground/t/edit/edit'                           # ...but we can still identify the edit marker
furl.parse '/otherground-forum/supportground/t/edit/edit/1234'                      # and know this is an edit url
furl.parse '/otherground-forum/supportground/t/new-thing'                  
furl.parse '/otherground-forum/supportground/t/new-thing/page/5'                    # pretty page urls are not a problem
furl.parse '/otherground-forum/supportground/t/this-is-a-test/edit/2108'
*/

# vim:fdm=indent
