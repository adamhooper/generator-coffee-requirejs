module.exports = (config) ->
  config.set
    autoWatch: false
    basePath: '..'
    browsers: [ 'PhantomJS' ]
    frameworks: [ 'mocha', 'requirejs' ]
    reporters: [ 'dots' ]

    files: [
      'app/scripts/config.js' # First RequireJS config call
      { pattern: 'app/bower_components/**/*.js', included: false }
      { pattern: 'app/scripts/**/*.js', included: false }
      { pattern: 'app/scripts/**/*.coffee', included: false }
      { pattern: 'test/scripts/**/*Spec.coffee', included: false }
      'test/test-main.coffee'
    ]
