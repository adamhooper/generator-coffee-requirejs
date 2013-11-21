tests = (file for file, __ of window.__karma__.files when /Spec\.(js|coffee)$/.test(file))

onLoaded = ->
  require [ 'chai' ], (chai) ->
    window.assert = chai.assert
    window.expect = chai.expect
    #window.should = chai.should()

    window.__karma__.start()

requirejs.config # Overriding previous config
  baseUrl: '/base/app/scripts'
  # leave paths and shims alone
  deps: tests
  callback: onLoaded
