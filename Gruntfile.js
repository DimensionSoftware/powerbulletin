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
          'app/js/main.js': 'app/main.ls'
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
    // FIXME needs to properly .kill & restart if pid exists
    //console.log(grunt.config('pid'));
    var cp = require('child_process'), proc = cp.exec('./bin/powerbulletin',
      function(error, stdout, stderr) { // sleep & restart on error
        if (error) {
          grunt.warn("b00m, sleeping before restart...\n"+ error);
          //setTimeout(proc, 2000);
        } else {
          console.log('done.');
        }
        //console.log(error ? error : 'done.');
      }
    );
    grunt.config.set('pid', proc.pid);
    console.log(grunt.config('pid'));
  });

  // Default task(s).
  grunt.registerTask('default', ['livescript', 'concat', 'uglify', 'launch', 'watch']);

};
