define = window?define or require(\amdefine) module
require, exports, module <- define

require! {
  fsm: \./fsm
}

{join, map, reject, scan, split-at, take, take-while} = require \prelude-ls
#
# making sense of our forum urls
#

# /forum                                forum
# /forum/sub-forum                      forum
# /forum/sub-forum/sub-sub-forum        forum
# /forum/censored                       moderation log
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
  * \moderation
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
  * \censored
  * \t
  * \page
*/

@type-of-part = (i) ->
  switch i
  | \page       => \page
  | \moderation => \moderation
  | \t          => \t
  | \edit       => \edit
  | \new        => \new
  | otherwise   =>
    if i.match /[\.]/ then return \fbdn #forbidden
    if i.match /^\d+$/ then \number else \string

@machine =
  initial:
    string     : \forum
    number     : \forum
    new        : \forum
    edit       : \forum
    moderation : \forum
    m          : \forum
    t          : \forum
    page       : \forum
    fbdn       : \error
  forum:
    string     : \forum
    number     : \forum
    new        : \new-thread
    edit       : \forum
    moderation : \moderation
    t          : \-thread-marker
    page       : \forum
    fbdn       : \error
  moderation   :
    string     : \error
    number     : \error
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  'new-thread':
    string     : \error
    number     : \error
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  '-thread-marker':
    string     : \thread
    number     : \thread
    new        : \thread
    edit       : \thread
    moderation : \thread
    m          : \thread
    t          : \thread
    page       : \thread
    fbdn       : \error
  thread:
    string     : \thread-permalink
    number     : \thread-permalink
    new        : \error
    edit       : \-edit-marker
    moderation : \error # instead of an error, this could point to a thread-level view of the moderation log
    m          : \thread-permalink
    t          : \error
    page       : \-page-marker
    fbdn       : \error
  'thread-permalink':
    string     : \error
    number     : \error
    new        : \error
    edit       : \-edit-marker
    moderation : \error
    m          : \error
    t          : \error
    page       : \-permalink-page-marker
    fbdn       : \error
  '-edit-marker':
    string     : \error
    number     : \edit
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  edit:
    string     : \error
    number     : \error
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  '-permalink-page-marker':
    string     : \error
    number     : \thread-permalink-page
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  'thread-permalink-page':
    string     : \error
    number     : \error
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  '-page-marker':
    string     : \error
    number     : \thread-page
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  'thread-page':
    string     : \error
    number     : \error
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error
  error:
    string     : \error
    number     : \error
    new        : \error
    edit       : \error
    moderation : \error
    m          : \error
    t          : \error
    page       : \error
    fbdn       : \error


# Given a URL path, return the type of forum url and the associated metadata
# @param String path
# @returns Object info about the forum url
@parse = (path) ->
  parts  = path?split '/' |> reject (-> it is '')
  inputs = map @type-of-part, parts
  type   = fsm.new-state @machine, \initial, inputs
  meta   = switch type
  | \initial               => { incomplete: true }
  | \forum                 => { forum-uri: "/#{parts.join '/'}" }
  | \moderation            => { forum-uri: "/#{parts[0 til parts.length - 1].join '/'}" }
  | \new-thread            => { forum-uri: "/#{parts[0 til parts.length - 1].join '/'}" }
  | \thread                => { forum-uri: @forum-uri(path), thread-uri: "/#{parts.join '/'}" }
  | \thread-page           =>
    [ uri-parts, [page, n] ] = split-at parts.length - 2, parts
    { forum-uri: @forum-uri(path), thread-uri: "/#{uri-parts.join '/'}", page: parseInt n }
  | \thread-permalink      =>
    { forum-uri: @forum-uri(path), thread-uri: "/#{parts.join '/'}", slug: parts[*-1] }
  | \thread-permalink-page =>
    [ uri-parts, [page, n] ] = split-at parts.length - 2, parts
    { forum-uri: @forum-uri(path), thread-uri: "/#{uri-parts.join '/'}", page: parseInt n }
  | \edit                  =>
    [ uri-parts, [edit, id] ] = split-at parts.length - 2, parts
    { forum-uri: @forum-uri(path), thread-uri: "/#{uri-parts.join '/'}", id: parseInt id }
  | otherwise              => { incomplete: true }
  { type, parts, path: "/#{parts.join '/'}" } <<< meta

# given a path, extract the forum-uri from it
# @param String path
# @returns String forum-uri part of path
@forum-uri = (path) ->
  parts  = path.split '/' |> reject (-> it is '')
  inputs = map @type-of-part, parts
  t = (state, input) ~>
    fsm.new-state @machine, state, [input]
  forum-states = scan t, \initial, inputs |> take-while (-> it is \initial or it is \forum)
  '/' + (parts |> take (forum-states.length - 1) |> join '/')

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

@

# vim:fdm=indent
