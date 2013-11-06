define = window?define or require(\amdefine) module
require, exports, module <- define

# Given a URL path, return the type of sales url and the associated metadata
# @param String path
# @returns Object info about the sales url
@parse = (path) ->
  type =
    switch path
    | \/              => \homepage
    | \/super         => \super
    | \/super/sites   => \superSites
    | \/super/users   => \superUsers
    | otherwise => \error

  if type is \error
    {path, type, +incomplete}
  else
    {path, type}

# opposite of parse
@gen = (route) ->
  switch route
  | \homepage   => \/
  | \super      => \/super
  | \superSites => \/super/sites
  | \superUsers => \/super/users

# component mappings
#TODO: create a high-level abstraction so we only have to define a components layout properties once
#      but still provide the same array interface to module.exports
@mappings =
  homepage    : [\Sales, \SalesApp, \.SalesApp-content]
  super       : [\SuperAdmin, \SalesApp, \.SalesApp-content]
  super-sites : [\SuperAdmin, \SalesApp, \.SalesApp-content]
  super-users : [\SuperAdmin, \SalesApp, \.SalesApp-content]

/*
Try these in the REPL.

surl.parse '/'
surl.parse '/super'
*/
@
# vim:fdm=indent
