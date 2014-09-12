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
    it 'should have a list of models passed in at construction time', () ->
      collection = new Collection([])
      collection.list.should.deep.equal []
    it 'should create a defensive copy of the list', () ->
      start = []
      collection = new Collection(start)
      start.push {some: "object"}
      collection.list.should.deep.equal []

  describe 'store()', () ->
    it 'should return an equivalent collection after storing with localforage', () ->
      collection = new Collection sampleData
      stored = collection.store()
      stored.should.eventually.be.an.instanceof Collection
      stored.should.eventually.deep.equal collection



