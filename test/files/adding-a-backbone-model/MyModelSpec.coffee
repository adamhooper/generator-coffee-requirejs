define [ 'models/MyModel' ], (MyModel) ->
  describe 'MyModel', ->
    beforeEach -> @subject = new MyModel()

    it 'should have an attribute', ->
      expect(@subject.get('foo')).to.equal('bar')
