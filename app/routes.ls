require! {
  './resources'
  './handlers'
  mw: './middleware'
}
global <<< require './helpers' # pull helpers into global (play nice :)


# <API RESOURCES>
# ---------
app.resource \posts   resources.posts
app.resource \threads resources.threads

# <PAGE HANDLERS & MISC.>
# ---------
app.get '/', mw.add-js(["/dynamic/js/layout.js"]), mw.add-css(['/dynamic/css/layout.styl,theme.styl']), handlers.homepage
app.get '/hello' handlers.hello

# dynamic serving
app.get '/dynamic/css/:file' handlers.stylus
app.get '/dynamic/js/:file'  handlers.js
