## Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'

module.exports = (grunt) ->
  require('time-grunt')(grunt)
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    yeoman:
      app: 'app'
      dist: 'dist'

    watch:
      coffee:
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee']
        tasks: ['coffee:dist']
      coffeeTest:
        files: ['test/scripts/{,*/}*.coffee']
        tasks: ['coffee:test']
      compass:
        files: ['<%= yeoman.app %>/styles/{,*/}*.{scss,sass}']
        tasks: ['compass:server', 'autoprefixer']
      styles:
        files: ['<%= yeoman.app %>/styles/{,*/}*.css']
        tasks: ['copy:styles', 'autoprefixer']

    connect:
      options:
        port: 9000
        # change this to '0.0.0.0' to access the server from outside
        hostname: 'localhost'
      test:
        options:
          base: [
            '.tmp'
            'test'
            '<%= yeoman.app %>'
          ]
      dist:
        options:
          open: true
          base: '<%= yeoman.dist %>'

    clean:
      dist:
        files: [{
          dot: true
          src: [
            '.tmp'
            '<%= yeoman.dist %>/*'
            '!<%= yeoman.dist %>/.git*'
          ]
        }]
      server: '.tmp'

    karma:
      options:
        configFile: 'test/karma.conf.coffee'
      continuous:
        singleRun: true

    coffee:
      dist:
        files: [{
          expand: true
          cwd: '<%= yeoman.app %>/scripts'
          src: '{,*/}*.coffee'
          dest: '.tmp/scripts'
          ext: '.js'
        }]
      test:
        files: [{
          expand: true
          cwd: 'test/spec'
          src: '{,*/}*.coffee'
          dest: '.tmp/spec'
          ext: '.js'
        }]

    compass:
      options:
        sassDir: '<%= yeoman.app %>/styles'
        cssDir: '.tmp/styles'
        generatedImagesDir: '.tmp/images/generated'
        imagesDir: '<%= yeoman.app %>/images'
        javascriptsDir: '<%= yeoman.app %>/scripts'
        fontsDir: '<%= yeoman.app %>/styles/fonts'
        importPath: '<%= yeoman.app %>/bower_components'
        httpImagesPath: '/images'
        httpGeneratedImagesPath: '/images/generated'
        httpFontsPath: '/styles/fonts'
        relativeAssets: false,
        assetCacheBuster: false
      dist:
        options:
          generatedImagesDir: '<%= yeoman.dist %>/images/generated'
      server:
        options:
          debugInfo: true

    autoprefixer:
      options:
        browsers: ['last 1 version']
      dist:
        files: [{
          expand: true
          cwd: '.tmp/styles/'
          src: '{,*/}*.css'
          dest: '.tmp/styles/'
        }]

    requirejs:
      dist:
        # Options: https://github.com/jrburke/r.js/blob/master/build/example.build.js
        options:
          # `name` and `out` is set by grunt-usemin
          baseUrl: '<%= yeoman.app %>/scripts',
          optimize: 'none',
          #  TODO: Figure out how to make sourcemaps work with grunt-usemin
          #  https://github.com/yeoman/grunt-usemin/issues/30
          # generateSourceMaps: true,
          #  required to support SourceMaps
          #  http://requirejs.org/docs/errors.html#sourcemapcomments

    rev:
      dist:
        files:
          src: [
            '<%= yeoman.dist %>/scripts/{,*/}*.js'
            '<%= yeoman.dist %>/styles/{,*/}*.css'
            '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp}'
            '<%= yeoman.dist %>/styles/fonts/{,*/}*.*'
          ]

    useminPrepare:
      options:
        dest: '<%= yeoman.dist %>'
      html: '<%= yeoman.app %>/index.html'

    usemin:
      options:
        dirs: ['<%= yeoman.dist %>']
      html: ['<%= yeoman.dist %>/{,*/}*.html']
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css']

    imagemin:
      dist:
        files: [{
          expand: true
          cwd: '<%= yeoman.app %>/images'
          src: '{,*/}*.{png,jpg,jpeg}'
          dest: '<%= yeoman.dist %>/images'
        }]

    svgmin:
      dist:
        files: [{
          expand: true
          cwd: '<%= yeoman.app %>/images'
          src: '{,*/}*.svg'
          dest: '<%= yeoman.dist %>/images'
        }]

    htmlmin:
      dist:
        options: {}
        files: [{
          expand: true
          cwd: '<%= yeoman.app %>'
          src: '*.html'
          dest: '<%= yeoman.dist %>'
        }]

    # Put files not handled in other tasks here
    copy:
      dist:
        files: [{
          expand: true
          dot: true
          cwd: '<%= yeoman.app %>'
          dest: '<%= yeoman.dist %>'
          src: [
            '*.{ico,png,txt}'
            '.htaccess'
            'images/{,*/}*.{webp,gif}'
            'styles/fonts/{,*/}*.*'
          ]
        }]
      styles:
        expand: true
        dot: true
        cwd: '<%= yeoman.app %>/styles'
        dest: '.tmp/styles/'
        src: '{,*/}*.css'

    concurrent:
      server: [
        'compass'
        'coffee:dist'
        'copy:styles'
      ]
      test: [
        'coffee'
        'copy:styles'
      ]
      dist: [
        'coffee'
        'compass'
        'copy:styles'
        'imagemin'
        'svgmin'
        'htmlmin'
      ]

    bower:
      all:
        rjsConfig: '<%= yeoman.app %>/scripts/config.js'

  grunt.registerTask 'server', (target) ->
    if target == 'dist'
      return grunt.task.run(['build', 'connect:dist:keepalive'])

    grunt.task.run([
      'clean:server'
      'concurrent:server'
      'autoprefixer'
      'watch'
    ])

  grunt.registerTask('test', [
    'clean:server'
    'concurrent:test'
    'autoprefixer'
    'connect:test'
    'karma:continuous'
  ])

  grunt.registerTask('build', [
    'clean:dist'
    'useminPrepare'
    'concurrent:dist'
    'autoprefixer'
    'requirejs'
    'concat',
    'cssmin',
    'uglify'
    'copy:dist'
    'rev'
    'usemin'
  ])

  grunt.registerTask('default', [
    'test',
    'build'
  ])
