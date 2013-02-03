require! {
  \mutant
  './mutants'
  './resources'
  './handlers'
  mmw: 'mutant/middleware'
  mw: './middleware'
}
global <<< require './helpers' # pull helpers (common) into global (play nice :)

# <API RESOURCES>
# ---------
app.resource \posts  resources.posts

# <PAGE HANDLERS & MISC.>
# ---------
common-js = [
  "#{cvars.cache3_url}/local/jquery.masonry.min.js",
  "#{cvars.cache2_url}/local/waypoints.min.js",
  "#{cvars.cache2_url}/local/waypoints-sticky.min.js",
  "#{cvars.cache4_url}/powerbulletin.min.js"]
common-css = [
  '/dynamic/css/theme.styl,layout.styl']

app.get '/',
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout('layout', mutants),
  handlers.homepage

app.get '/:forum',
  mw.add-js(common-js),
  mw.add-css(common-css),
  mmw.mutant-layout('layout', mutants),
  handlers.forum

app.get '/hello' handlers.hello

# UI SKETCH UP:
#
# Connect to a social network:
# Facebook, Twitter
# OR
# Register @ <Forum Name>.com
# # post endpoint
app.post '/ajax/register', handlers.register
# todo html for use in fancybox or modal dialog at get route

# html for use in fancybox or modal dialog
app.get '/ajax/add-post', handlers.add-post-html
# todo post endpoint for adding a post
app.post '/ajax/add-post', handlers.add-post

# dynamic serving
app.get '/dynamic/css/:file' handlers.stylus

cvars.surfable-routes = mutant.surfable-routes app
