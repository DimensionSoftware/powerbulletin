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
        entries: 'app/layout.ls',
        beforeHook: function(bundle) { bundle.use(require('livescript-browserify')); }
      }
    },

    launch: {
      options: {
        pid: false
      }
    },

    watch: {
      app: {
        files: ['app/*.ls', 'config/*', 'lib/**/*.ls'],
        tasks: ['browserify', 'uglify', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 2000
        }
      },
      voltdb: {
        files: ['voltdb/procs/*.java', 'voltdb/procs/*.clj'],
        tasks: ['voltdb', 'launch'],
        options: {
          interrupt: true,
          debounceDelay: 2000
        }
      }
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

  // Compile VoltDB Procedures and Launch VoltDB
  grunt.registerTask('voltdb', 'Compile VoltDB Procedures!', function() {
    var config  = require('./config/development');
    var pidFile = config.tmp+'/voltdb.pid';
    var logFile = 'voltdb.log';

    var now = new Date();
    fs.appendFileSync(logFile, "\n" + now.toISOString() + " - Recompiling VoltDB Procedures...\n");

    var result  = exec("./bin/compile-voltdb", { silent: true });
    fs.appendFileSync(logFile, result.output);
    if (result.code == 0) {
      daemon('./bin/launch-voltdb', pidFile, logFile);
      setTimeout(launch, 10000);
    }
  });

  // Default task(s).
  grunt.registerTask('default', ['browserify', 'uglify', 'launch', 'voltdb', 'watch']);

};
