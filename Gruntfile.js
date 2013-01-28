
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
          'lib/pb-entry/index.js': 'lib/pb-entry/index.ls',
          'lib/validations/index.js': 'lib/validations/index.ls',
          'public/powerbulletin.js': 'app/layout.ls',
        }
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
        tasks: ['livescript', 'uglify', 'launch'],
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

  grunt.registerTask('launch', 'Launch PowerBulletin!', function() {
    // XXX surely there's a more automatic way to manage this?
    var cp   = require('child_process'),
        fs   = require('fs'),
        pid  = false

    config = require('./config/development');
    file   = config.tmp+'/pb.pid';

    try { // kill running proc
      pid = fs.readFileSync(file, 'utf8');
      if (pid) process.kill(-pid); // the minus kills the entire process group
    } catch (e) {}

    // compile pb-entry with component (tjholowaychauk or however u say his name)
    //cp.spawn('./bin/compile-pb-entry', [], {detached:true, stdio:'inherit'});
    //console.log(" ... compiling pb entry");

    // spawn detached new proc & write out pid
    proc = cp.spawn('./bin/powerbulletin', [], {detached:true, stdio:'inherit'});
    fs.writeFileSync(file, proc.pid)
  });

  // Default task(s).
  grunt.registerTask('default', ['livescript', 'uglify', 'launch', 'watch']);

};
