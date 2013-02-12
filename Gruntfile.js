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

    livescript: {
      compile: {
        files: {
        }
      }
    },

    browserify: {
      'public/powerbulletin.js' : {
        entries: ['app/layout.ls', 'app/entry.ls'],
        ignore: ['jsdom'],
        beforeHook: function(bundle) { bundle.use(require('livescript-browserify')); }
      }
    },

    launch: {
      options: {
        pid: false
      }
    },

    watch: {
      procs: {
        files: ['plv8_modules/*.ls', 'plls-procedure-test.sql'],
        tasks: ['procs', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 500
        }
      },
      jade: {
        files: ['app/views/*.jade'],
        tasks: ['jade', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 500
        }
      },
      app: {
        files: ['app/*.ls', 'config/*', 'lib/**/*.ls'],
        tasks: ['browserify', 'uglify', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 500
        }
      },
    }
  });

  // Load the plugins
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-livescript');
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
    var config = require('./config/development');
    var file   = config.tmp+'/pb.pid';

    daemon('./bin/powerbulletin', file);
  });

  grunt.registerTask('procs', 'Compile stored procedures to JS', function() {
    exec('node_modules/.bin/lsc -c plv8_modules/*.ls', {silent:true});
    exec('bin/psql pb < plls-procedure-test.sql', {silent: true});
  });
  grunt.registerTask('jade', 'Compile ClientJade/Mutant templates!', function() {
    fs.writeFileSync('app/views/mutants.js', (exec('node_modules/.bin/clientjade -c app/views/homepage.jade app/views/nav.jade app/views/posts.jade', {silent:true}).output));
  });

  // Default task(s).
  grunt.registerTask('default', ['procs', 'jade', 'browserify', 'uglify', 'launch', 'watch']);

};
