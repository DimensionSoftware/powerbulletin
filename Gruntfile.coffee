require "shelljs/global"
require 'LiveScript'
async      = require('async')
cp         = require('child_process')
fs         = require('fs')
h          = require('./app/server-helpers')
config     = require('./config/common')
module.exports = (grunt) ->
  
  # Project configuration.
  # for all our js minification needs
  
  #{{{ Load the plugins
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  #}}}

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    uglify: # TODO try uglify2 against components with --no-mangle
      options:
        mangle:
          except: # XXX don't mangle Components
            fs.readdirSync('component', 'utf8')
              .filter((f) -> f.match /\.ls$/)
              .map((f) -> f.replace /\.ls$/, '')
      dist:
        files: []
          #"public/powerbulletin.min.js": "public/powerbulletin.js"
          #"public/powerbulletin-sales.min.js": "public/powerbulletin-sales.js"

    watch:
      procs:
        files: ["plv8_modules/*.ls", "procedures.sql"]
        tasks: ["procs", "launch"]
        options:
          debounceDelay: 50
          interrupt: true

      clientJade:
        files: ["app/views/*.jade"]
        tasks: ["clientJade", "launch"]
        options:
          debounceDelay: 50
          interrupt: true

      componentJade:
        files: ["component/*.jade"]
        tasks: ["componentJade", "launch"]
        options:
          debounceDelay: 50
          interrupt: true

  #{{{ daemonize a command
  # - possibly not needed anymore, bin/powerbulletin wipes :)
  daemon = (command, pidFile, logFile) ->
    pid = false
    try # kill running proc
      pid = fs.readFileSync(pidFile, "utf8")
      process.kill -pid  if pid # the minus kills the entire process group
    opts =
      detached: true
      stdio: "inherit"

    if logFile
      log = fs.openSync(logFile, "a")
      opts.stdio = ["ignore", log, log]
    proc = cp.spawn(command, [], opts)
    fs.writeFileSync pidFile, proc.pid
  #}}}
#{{{ Backend tasks
  grunt.registerTask "launch", "Launch PowerBulletin!", launch = ->
    if process.env.NODE_ENV is "production"
      daemon "./bin/powerbulletin", config.tmp + "/pb.pid"
    else
      #exec "bin/develop &", async:true
      daemon "./bin/develop", config.tmp + "/develop.pid"

  grunt.registerTask "procs", "Compile stored procedures to JS", ->
    done = this.async()
    exec "node_modules/.bin/lsc -c plv8_modules/*.ls"
    exec "bin/psql pb < procedures.sql",
      silent: true
    done()
#}}}
  #{{{ Frontend tasks
  grunt.registerTask "clientJade", "compile regular jade", ->
    done = this.async()
    exec "bin/build-client-jade"
    done()

  grunt.registerTask "componentJade", "compile component Jade", ->
    done = this.async()
    exec "bin/build-component-jade"
    done()

  grunt.registerTask 'css', 'Build master.css for all themes', ->
    done = this.async()
    h.renderCss('master.styl', (err, blocks) ->
      fs.writeFileSync 'public/master.css', blocks
      h.renderCss('master-sales.styl', (err, blocks) ->
        fs.writeFileSync 'public/master-sales.css', blocks
        done(true)))
  #}}}

  # Default task(s).
  if process.env.NODE_ENV is "production"
    grunt.registerTask "default", ["launch"] # launch handles everything
  else
    grunt.registerTask "default", ["procs", "clientJade", "componentJade", "launch", "watch"]

process.on 'SIGINT', ->
  exec "killall -s INT -r pb-worker"
  process.exit()

# vim:fdm=marker
