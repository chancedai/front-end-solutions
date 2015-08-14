module.exports = function(grunt){
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    stylus: {
      compile: {
        options: {
          compress: false,
          banner: '/*!\n' +
            '* <%= pkg.name %>\n' +
            '* <%= grunt.template.today("yyyy-mm-dd hh:ss") %>\n' +
            '*/\n'
        },
        files: {
          'comment/css/comment.min.css': 'comment/css/src/comment.styl'
        }
      }
    },
    watch: {
      scripts: {
        files: ['Gruntfile.js', 'comment/css/src/*.styl'],
        tasks: ['stylus']
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-stylus');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.registerTask('default', ['watch']);
  grunt.registerTask('build', [
    'stylus'
  ]);
};
