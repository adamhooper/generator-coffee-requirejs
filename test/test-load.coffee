assert = require('assert');

describe 'coffee-requirejs generator', ->
  it 'can be imported without blowing up', ->
    app = require('../app')
    assert.ok(app)
