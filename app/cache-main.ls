require! \./CacheApp

c = new CacheApp(process.argv.2)

err <- c.start
if err then throw err
# vim:fdm=marker
