
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    concat: {
      options: {
        // define a string to put between each file in the concatenated output
        separator: ';'
      },
      dist: {
        src:  [], // XXX none need concat yet
        dest: 'public/js/<%= pkg.name %>.js'
      }
    },

    uglify: { // for all our js minification needs
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      dist: {
        files: {
          'public/js/<%= pkg.name %>.min.js': ['<%= concat.dist.dest %>']
        }
      }
    },

    livescript: {
      compile: {
        files: {
          'app/js/main.js'     : 'app/main.ls',
          'public/js/layout.js': 'app/layout.ls'
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
        files: ['app/*.ls'],
        tasks: ['livescript', 'launch'],
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

    config = JSON.parse(fs.readFileSync('./config.json', 'utf8'));
    file   = config.tmp+'/pb.pid';

    try { // kill running proc
      pid = fs.readFileSync(file, 'utf8');
      if (pid) process.kill(-pid); // the minus kills the entire process group
    } catch (e) {}

    // spawn detached new proc & write out pid
    proc = cp.spawn('./bin/powerbulletin', [], {detached:true, stdio:'inherit'});
    fs.writeFileSync(file, proc.pid)
  });

  // Default task(s).
  grunt.registerTask('default', ['livescript', 'concat', 'uglify', 'launch', 'watch']);

};
