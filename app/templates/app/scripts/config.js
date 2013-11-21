requirejs.config({
  shim: {
    'backbone': {
      exports: 'Backbone',
      // jquery isn't strictly a dependency of Backbone 1.1.0. You may remove
      // it from this list if you know what you're doing.
      deps: [ 'underscore', 'jquery' ]
    },
  },
  paths: {
    // paths will be set by grunt-bower-requirejs
  }
});
