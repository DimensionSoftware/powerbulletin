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


/*
Try these in the REPL.

surl.parse '/'
surl.parse '/super'
*/
@
# vim:fdm=indent
