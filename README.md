# generator-coffee-requirejs [![Build Status](https://secure.travis-ci.org/adamhooper/generator-coffee-requirejs.png?branch=master)](https://travis-ci.org/adamhooper/generator-coffee-requirejs)

A generator for [Yeoman](http://yeoman.io).

## Features

* RequireJS: this helps you write modular code.
* BDD testing with Mocha+Chai+Sinon+Squire.js: this helps you test. (Why not Jasmine? Because [Yeoman prefers Mocha](https://github.com/yeoman/yeoman/issues/117))
* Karma test running: this helps you test automatically across multiple browsers and PhantomJS.
* Some [generator-webapp](https://github.com/yeoman/generator-webapp) features:
    * Automagically compile CoffeeScript & Compass
    * Awesome Image Optimization (via OptiPNG, pngquant, jpegtran and gifsicle)
    * Mocha Unit Testing with PhantomJS

Some features of generator-webapp are _not_ implemented:

* Automagically lint your scripts: omitted because I'm lazy and I use CoffeeScript.
* CSS autoprefixing: omitted for simplicity.
* Built-in preview server with LiveReload: omitted for IE8 compatibility.
* Twitter Bootstrap for Sass: omitted because you can `bower install` it instead.
* Modernizr: omitted because it's often not necessary.

## Getting Started

* Install: `npm install -g generator-coffee-requirejs`
* Run: `yo coffee-requirejs`
* Run `grunt` for building, `grunt test` for testing and `grunt server` for a live preview

## Doing stuff

Here are a few useful tasks that might help you get a hang for how to edit the resulting web app.

### To add a Backbone model and view

1. `bower install --save jquery underscore backbone` to download Backbone.
1. `grunt bower` to add the path to `app/scripts/config.js`.
1. Add `test/scripts/models/MyModelSpec.coffee` with something like this:
    define [ 'models/MyModel' ], (MyModel) ->
      describe 'MyModel', ->
        it 'should have a "foo" attribute', ->
          subject = new MyModel()
          expect(subject.get('foo')).to.equal('bar')
1. Run `grunt test` to see the failure
1. Add `app/scripts/models/MyModel.coffee` with something like this:
    define [ 'backbone' ], (Backbone) ->
      class MyModel extends Backbone.Model
        defaults:
          foo: 'bar'
1. Run `grunt test` to see it pass

Notes:

* If you want to use Backbone without jQuery, edit `app/scripts/config.js` to remove the dependency.

### To test modules with dependency injection

You love mocking and stubbing, but RequireJS sometimes makes that difficult. For instance, how can you stub out jQuery without touching global variables?

You can do it with [Squire.js](https://github.com/iammerrick/Squire.js/) like this:

1. `bower install jquery` to download jQuery.
1. `grunt bower` to add the path to `app/scripts/config.js`.
1. Add `test/scripts/wonkyUtilSpec.coffee` with something like this:
    define [ 'Squire' ], (Squire) ->
      describe 'wonkyUtil', ->
        mockJQuery =
          queue: (fn) -> fn.call(this)
        injector = new Squire('with stubbed jQuery')
        injector.mock('jquery', mockJQuery)
        injector.require [ 'wonkyUtil' ], (wonkyUtil) ->
          describe 'with stubbed jQuery', ->
            it 'should queue something using $.queue()', ->
              mockJQuery.queue = sinon.spy()
              fn = () ->
              wonkyUtil.doSomething(fn)
              expect(mockjQuery.queue).to.have.been.calledWith(fn)
1. Run `grunt test` to see the failure
1. Add `app/scripts/wonkyUtil.coffee` with something like this:
    define [ 'jquery' ], ($) ->
      doSomething: (fn) ->
        $.queue(fn)
1. Run `grunt test` to see it pass

### To test continuously

Run `grunt autotest`. Autotest will run when any CoffeeScript or JavaScript file changes.

Press Ctrl-C to stop.

## Contributing

This is a test-driven project. Tests are far more important than implementation. Test the generator using `grunt test`, and test it continually with `grunt autotest`.

Pull requests are welcome; I'm likely to merge a pull request with attached tests.

## License

Public domain
