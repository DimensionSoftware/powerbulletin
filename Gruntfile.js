require('shelljs/global');
var cp = require('child_process'),
    fs = require('fs');

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

    launch: {
      options: {
        pid: false
      }
    },

    watch: {
      procs: {
        files: ['plv8_modules/*.ls', 'procedures.sql'],
        tasks: ['procs', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 100
        }
      },
      livescript: {
        files: ['app/main.ls'],
        tasks: ['livescript'],
        options: {
          interrupt: true,
          debounceDelay: 100
        }
      },
      clientJade: {
        files: ['app/views/*.jade'],
        tasks: ['clientJade'],
        options: {
          debounceDelay: 100
        }
      },
      componentJade: {
        files: ['component/*.jade'],
        tasks: ['componentJade'],
        options: {
          debounceDelay: 100
        }
      },
      app: {
        files: ['component/*.ls', 'app/*.ls', 'config/*', 'lib/**/*.ls', 'app/views/templates.js', 'build/component-templates.js'],
        tasks: ['browserify', 'launch'],
        options: {
          debounceDelay: 100
        }
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
    var config = require('./config/common');
    var file   = config.tmp+'/pb.pid';
    daemon('./bin/powerbulletin', file);

    if (process.NODE_ENV != 'production') grunt.task.run('watch');
  });

  grunt.registerTask('livescript', 'compile ls -> js', function() {
    exec('node_modules/.bin/lsc -c app/main.ls');
  });

  grunt.registerTask('procs', 'Compile stored procedures to JS', function() {
    exec('node_modules/.bin/lsc -c plv8_modules/*.ls');
    exec('bin/psql pb < procedures.sql', {silent: true});
  });

  grunt.registerTask('clientJade', 'compile regular jade', function() {
    // XXX: should move this into bin/build-clientjade eventually
    fs.writeFileSync('app/views/templates.js', (exec('node_modules/.bin/clientjade -c app/views/homepage.jade app/views/order-control.jade app/views/thread.jade app/views/nav.jade app/views/posts.jade app/views/post-edit.jade app/views/post-new.jade app/views/profile.jade app/views/posts-by-user.jade app/views/post.jade app/views/admin-*.jade app/views/search.jade app/views/search-filters.jade app/views/search-facets.jade app/views/_*.jade', {silent:true}).output));
  });

  grunt.registerTask('componentJade', 'compile component Jade', function() {
    exec('bin/build-component-jade');
  });

  grunt.registerTask('browserify', 'generate browser bundle', function() {
    exec('bin/build-browser-bundle');
  });

  // Default task(s).
  if (process.NODE_ENV == 'production')
    grunt.registerTask('default', ['procs', 'clientJade', 'componentJade', 'livescript', 'browserify', 'uglify', 'launch']);
  else
    grunt.registerTask('default', ['procs', 'clientJade', 'componentJade', 'livescript', 'browserify', 'launch']);
};
