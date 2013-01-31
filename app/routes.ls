require! {
  \mutant
  './mutants'
  './resources'
  './handlers'
  mw: './middleware'
}
global <<< require './helpers' # pull helpers (common) into global (play nice :)

# <API RESOURCES>
# ---------
app.resource \posts  resources.posts

# <PAGE HANDLERS & MISC.>
# ---------
app.get '/',
  mw.add-js([
    "#{cvars.cache3_url}/local/jquery.masonry.min.js",
    "#{cvars.cache2_url}/local/waypoints.min.js",
    "#{cvars.cache4_url}/powerbulletin.min.js"]),
  mw.add-css(['/dynamic/css/theme.styl,layout.styl']),
  handlers.homepage

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
