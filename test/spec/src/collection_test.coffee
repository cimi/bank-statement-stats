createDateString = (date) ->
  moment(date).format('YYYY-MM-DD');

sampleData = [
  new Payment({
    date: createDateString(new Date('2013-11-19')),
    name: 'Some payment',
    ammount: 100,
    balance: 0
  }),
  new Payment({
    date: createDateString(new Date('2013-11-13')),
    name: 'Some payment',
    ammount: 100,
    balance: 0
  })
]

describe "Collection", () ->
  describe 'constructor(list)', () ->
    it 'should throw an error if the input is not an array', () ->
      expect(() -> new Collection {}).to.throw("Collection must be created from an array, received " + {})
    it 'should have a list of models passed in at construction time', () ->
      collection = new Collection([])
      collection.list.should.deep.equal []
    it 'should create a defensive copy of the list', () ->
      initial = []
      collection = new Collection(initial)
      initial.push {some: "object"}
      collection.list.should.deep.equal []
    it 'should throw an error if the models are not of the same type', () ->
      badConstructor = () -> new Collection [sampleData[0], {}]
      expect(badConstructor).to.throw "Models are not of the same type, seen Payment,Object"

  describe 'store()', () ->
    it 'should return an equivalent collection after storing with localforage', () ->
      collection = new Collection sampleData
      stored = collection.store()
      stored.should.eventually.be.an.instanceof Collection
      stored.should.eventually.deep.equal collection

    it 'should throw an Error if the underlying models do not offer a store() method', () ->
      collection = new Collection [{}]
      expect(() -> collection.store()).to.throw "Model object Object does not have a store method"

