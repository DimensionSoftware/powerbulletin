require "shelljs/global"
cp = require("child_process")
fs = require("fs")
config = require("./config/common")
module.exports = (grunt) ->
  
  # Project configuration.
  # for all our js minification needs
  
  # Load the plugins
  
  # daemonize a command
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
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    uglify:
      dist:
        files:
          "public/powerbulletin.min.js": "public/powerbulletin.js"

    watch:
      procs:
        files: ["plv8_modules/*.ls", "procedures.sql"]
        tasks: ["procs", "browserify", "launch"]
        options:
          debounceDelay: 250
          interrupt: true

      livescript:
        files: ["app/main.ls"]
        tasks: ["livescript", "browserify", "launch"]
        options:
          debounceDelay: 250
          interrupt: true

      clientJade:
        files: ["app/views/*.jade"]
        tasks: ["clientJade", "browserify", "launch"]
        options:
          debounceDelay: 250
          interrupt: true

      componentJade:
        files: ["component/*.jade"]
        tasks: ["componentJade", "browserify", "launch"]
        options:
          debounceDelay: 250
          interrupt: true

      app:
        files: ["component/*.ls", "app/*.ls", "config/*", "lib/**/*.ls"]
        tasks: ["browserify", "launch"]
        options:
          debounceDelay: 250
          interrupt: true

  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  launch = undefined
  isLaunched = false
  grunt.registerTask "launch", "Launch PowerBulletin!", launch = ->
    isLaunched = ! exec('ps aux | grep pb-worker | grep -v grep', {silent: true}).code

    if isLaunched
      # soft reload
      console.log 'soft reload'
      exec "killall -HUP -r pb-worker"
    else
      # initial load
      console.log 'initial load'
      exec "killall -9 -r pb-worker powerbulletin",
        silent: true
    
      # XXX surely there's a more automatic way to manage this?
      daemon "./bin/powerbulletin", config.tmp + "/pb.pid"

  grunt.registerTask "livescript", "compile ls -> js", ->
    exec "node_modules/.bin/lsc -c app/main.ls"

  grunt.registerTask "procs", "Compile stored procedures to JS", ->
    exec "node_modules/.bin/lsc -c plv8_modules/*.ls"
    exec "bin/psql pb < procedures.sql",
      silent: true

  grunt.registerTask "clientJade", "compile regular jade", ->
    exec "bin/build-client-jade"

  grunt.registerTask "componentJade", "compile component Jade", ->
    exec "bin/build-component-jade"

  grunt.registerTask "browserify", "generate browser bundle", ->
    exec "killall -9 build-browser-bundle",
      silent: true
    daemon "bin/build-browser-bundle", config.tmp + "/browserify.pid"

  
  # Default task(s).
  if process.NODE_ENV is "production"
    grunt.registerTask "default", ["procs", "clientJade", "componentJade", "livescript", "browserify", "uglify", "launch"]
  else
    grunt.registerTask "default", ["procs", "clientJade", "componentJade", "livescript", "browserify", "launch", "watch"]

process.on 'SIGINT', ->
  exec "killall -9 -r pb-worker"
  process.exit()
