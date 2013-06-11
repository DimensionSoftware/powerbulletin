require('shelljs/global');
var cp     = require('child_process'),
    fs     = require('fs'),
    config = require('./config/common');

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    uglify: { // for all our js minification needs
      dist: {
        files: {
          'public/powerbulletin.min.js': 'public/powerbulletin.js'
        }
      }
    },

    watch: {
      procs: {
        files: ['plv8_modules/*.ls', 'procedures.sql'],
        tasks: ['procs', 'browserify', 'launch'],
        options: {debounceDelay: 250, interrupt:true, nospawn:true}
      },
      livescript: {
        files: ['app/main.ls'],
        tasks: ['livescript', 'browserify', 'launch'],
        options: {debounceDelay: 250, interrupt:true, nospawn:true}
      },
      clientJade: {
        files: ['app/views/*.jade'],
        tasks: ['clientJade', 'browserify', 'launch'],
        options: {debounceDelay: 250, interrupt:true, nospawn:true}
      },
      componentJade: {
        files: ['component/*.jade'],
        tasks: ['componentJade', 'browserify', 'launch'],
        options: {debounceDelay: 250, interrupt:true, nospawn:true}
      },
      app: {
        files: ['component/*.ls', 'app/*.ls', 'config/*', 'lib/**/*.ls'],
        tasks: ['browserify', 'launch'],
        options: {debounceDelay: 250, interrupt:true, nospawn:true}
      },
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // daemonize a command
  function daemon(command, pidFile, logFile) {
    var pid = false;

    try { // kill running proc
      pid = fs.readFileSync(pidFile, 'utf8');
      if (pid) process.kill(-pid); // the minus kills the entire process group
    } catch (e) {}

    var opts = { detached: true, stdio: 'inherit' };
    if (logFile) {
      var log = fs.openSync(logFile, 'a');
      opts.stdio = [ 'ignore', log, log ];
    }
    var proc = cp.spawn(command, [], opts);
    fs.writeFileSync(pidFile, proc.pid)
  }

  var launch;
  grunt.registerTask('launch', 'Launch PowerBulletin!', launch = function() {
    exec('killall -9 pb-supervisor pb-worker powerbulletin', {silent:true});
    // XXX surely there's a more automatic way to manage this?
    daemon('./bin/powerbulletin', config.tmp+'/pb.pid');
  });

  grunt.registerTask('livescript', 'compile ls -> js', function() {
    exec('node_modules/.bin/lsc -c app/main.ls');
  });

  grunt.registerTask('procs', 'Compile stored procedures to JS', function() {
    exec('node_modules/.bin/lsc -c plv8_modules/*.ls');
    exec('bin/psql pb < procedures.sql', {silent: true});
  });

  grunt.registerTask('clientJade', 'compile regular jade', function() {
    exec('bin/build-client-jade');
  });

  grunt.registerTask('componentJade', 'compile component Jade', function() {
    exec('bin/build-component-jade');
  });

  grunt.registerTask('browserify', 'generate browser bundle', function() {
    //exec('bin/build-browser-bundle');
    exec('killall -9 build-browser-bundle', {silent:true});
    daemon('bin/build-browser-bundle', config.tmp+'/browserify.pid');
  });

  // Default task(s).
  if (process.NODE_ENV == 'production')
    grunt.registerTask('default', ['procs', 'clientJade', 'componentJade', 'livescript', 'browserify', 'uglify', 'launch']);
  else
    grunt.registerTask('default', ['procs', 'clientJade', 'componentJade', 'livescript', 'browserify', 'launch', 'watch']);
};
