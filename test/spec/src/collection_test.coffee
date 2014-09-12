describe "Collection", () ->
  describe 'constructor(list)', () ->
    it 'should have a list of models passed in at construction time', () ->
      collection = new Collection([])
      collection.list.should.deep.equal []
    it 'should create a defensive copy of the list', () ->
      start = []
      collection = new Collection(start)
      start.push {some: "object"}
      collection.list.should.deep.equal []

