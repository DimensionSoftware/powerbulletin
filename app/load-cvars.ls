require! \fs

try # load config.json
  global.cvars = require '../config/common'
  global.cvars <<< require "../config/#{process.env.NODE_ENV or \development}"

  try
    global.cvars <<< require '../config/local' # local settings which aren't in version control
  catch
    # do nothing

  global.cvars.env = process.env.NODE_ENV
  global.cvars.process-start-date = new Date!
  global.cvars.acceptable-stylus-files = fs.readdir-sync \app/stylus/
catch e
  console.error "Inspect config.json: #{e}"
  process.exit!
 
