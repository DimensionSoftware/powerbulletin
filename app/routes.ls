
require! {
  './resources'
  './handlers'
  mw: './middleware'
}

# <API RESOURCES>
# ---------
app.resource 'threads' resources.threads


# <PAGES & MISC.>
# ---------
app.get '/hello' handlers.hello
