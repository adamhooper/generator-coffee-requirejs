define [ 'backbone' ], (Backbone) ->
  class MyModel extends Backbone.Model
    defaults:
      foo: 'bar'
