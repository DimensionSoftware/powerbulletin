require('shelljs/global');
var cp = require('child_process'),
    fs = require('fs');

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    //concat: {
    //  options: {
    //    // define a string to put between each file in the concatenated output
    //    separator: ';'
    //  },
    //  dist: {
    //    src:  [], // XXX none need concat yet
    //    dest: 'public/<%= pkg.name %>.js'
    //  }
    //},

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
      jade: {
        files: ['app/views/*.jade'],
        tasks: ['jade', 'browserify', 'uglify', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 100
        }
      },
      app: {
        files: ['app/*.ls', 'config/*', 'lib/**/*.ls'],
        tasks: ['browserify', 'uglify', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 100
        }
      },
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-browserify');

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
    // XXX surely there's a more automatic way to manage this?
    var config = require('./config/common');
    var file   = config.tmp+'/pb.pid';
    exec('killall -9 pb-supervisor pb-worker powerbulletin', {silent:true});
    daemon('./bin/powerbulletin', file);
  });

  grunt.registerTask('livescript', 'compile ls -> js', function() {
    exec('node_modules/.bin/lsc -c app/main.ls');
  });

  grunt.registerTask('procs', 'Compile stored procedures to JS', function() {
    exec('node_modules/.bin/lsc -c plv8_modules/*.ls');
    exec('bin/psql pb < procedures.sql', {silent: true});
  });
  grunt.registerTask('jade', 'Compile ClientJade/Mutant templates!', function() {
    fs.writeFileSync('app/views/templates.js', (exec('node_modules/.bin/clientjade -c app/views/homepage.jade app/views/order-control.jade app/views/thread.jade app/views/nav.jade app/views/posts.jade app/views/post-edit.jade app/views/post-new.jade app/views/profile.jade app/views/posts-by-user.jade app/views/post.jade app/views/admin-*.jade app/views/search.jade app/views/search-filters.jade app/views/search-facets.jade app/views/_*.jade', {silent:true}).output));
  });

  grunt.registerTask('browserify', 'generate browser bundle', function() {
    exec('node_modules/.bin/browserify --ignore cheerio --ignore jade --ignore jsdom --plugin livescript-browserify -o public/powerbulletin.js app/layout.ls app/pb-entry.ls');
  });

  // Default task(s).
  grunt.registerTask('default', ['procs', 'jade', 'livescript', 'browserify', 'uglify', 'launch', 'watch']);

};
