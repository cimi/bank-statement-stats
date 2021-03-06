# global describe, it
TIMEOUT = 20 # milliseconds
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
  }),
  new Payment({
    date: createDateString(new Date('2013-11-13')),
    name: 'Some payment',
    ammount: 100,
    balance: 0
  }),
  new Payment({
    date: createDateString(new Date('2013-11-17')),
    name: 'Some payment',
    ammount: 100,
    balance: 0
  })
]
data = []
describe 'Payment', () ->
  beforeEach (done) ->
    data = new Payments(sampleData).clone().list
    localforage.clear().then () -> done()

  describe 'constructor(options)', () ->
    it 'should get a unique guid at creation time if not passed in', () ->
      payment = new Payment({})
      payment.guid.length.should.equal 36
      payment.guid.split('-').should.have.length 5

    it 'should keep properties received at creation time', () ->
      payment = new Payment(data[0])
      payment.should.deep.equal data[0]

  describe 'isEquivalent(other)', () ->
    it 'should return equivalent if a payment has the same details', () ->
      sampleData[1].isEquivalent(sampleData[2]).should.be.true
      sampleData[1].isEquivalent(sampleData[3]).should.be.false

  describe 'hashDetails()', () ->
    it 'should generate a consistent hash out of date, ammount, name and balance', () ->
      sampleData[1].hashDetails().should.equal sampleData[2].hashDetails()
      sampleData[1].hashDetails().should.not.equal sampleData[3].hashDetails()

  describe 'getKey()', () ->
    it 'should generate key string "payments/<date>/<guid>"', () ->
      payment = new Payment sampleData[0]
      payment.date = new Date()
      expected = moment(payment.date).format('YYYY-MM-DD')
      payment.getKey().should.equal 'payments/' + expected + '/' + payment.guid

  describe 'store()', () ->
    it 'should save the Payment under payment.getKey()', () ->
      data[0].store().then () ->
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT))
      .then () ->
        localforage.getItem(data[0].getKey()).then (obj) -> new Payment(obj)
        .should.eventually.deep.equal data[0]

    it 'should return the Payment', () ->
      payment = sampleData[0]
      payment.store().should.eventually.deep.equal payment

describe 'Payments', () ->
  beforeEach (done) ->
    localforage.clear().then () -> done()
    @data = new Payments(sampleData).clone().list

  describe 'constructor(@list)', () ->
    it 'should create a defensive copy of the list received', () ->
      payments = new Payments @data
      @data.push @data[0]
      payments.list.should.have.length 4

  describe 'clone()', () ->
    it 'should return a new collection with a copy of all the elments in the original one', () ->
      payments = new Payments @data
      cloned = payments.clone()

      cloned.list.shift()
      payments.list.should.have.length 4
      cloned.list.should.have.length 3

      payments.list[1].name = 'Some other payment'
      cloned.list[0].name.should.equal 'Some payment'

  describe 'isEquivalent(other)', () ->
    it 'should return true if individual payments are equivalent', () ->
      payments1 = new Payments @data
      payments2 = new Payments _.clone @data
      payments1.isEquivalent(payments2).should.be.true

    it 'should return false if the other collection has different payments', () ->
      payments1 = new Payments @data
      @data.push @data[0]
      payments2 = new Payments @data
      payments1.isEquivalent(payments2).should.be.false

  describe 'storeAll()', () ->
    it 'should return a Payments object after saving', () ->
      payments = new Payments sampleData
      payments = payments.storeAll()
      payments.should.eventually.be.an.instanceof Payments

    it 'should save a list of payments to localstorage, regardless of what other values are present', () ->
      payments = new Payments @data
      payments.storeAll().then (payments) ->
        payments.list.forEach (payment) ->
          localforage.getItem(payment.getKey()).then (stored) -> new Payment(stored)
          .should.eventually.deep.equal payment

  describe 'storeDiff()', () ->
    it 'should append the difference of the two lists to storage', () ->
      payments1 = new Payments @data
      extra = new Payment @data[1]
      extra.guid = new Payment({}).guid
      @data.push extra
      payments2 = new Payments @data
      payments1.storeAll().then () ->
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT))
      .then () ->
        payments2.storeDiff().then () ->
          new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT))
        .then () ->
          payments = Payments.load({from: '2013-11-13'}).then (payments) ->
            payments.list.should.have.length 3
            payments.list.should.contain.a.thing.with.property 'guid', extra.guid

    it 'should return Payments wrapping all saved Payment objects', () ->
      payments1 = new Payments @data
      extra = new Payment @data[1]
      extra.guid = new Payment({}).guid
      @data.push extra
      payments2 = new Payments @data
      payments1.storeAll().then () ->
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT))
      .then () ->
        payments2.storeDiff().then (stored) ->
          stored.should.be.an.instanceof Payments
          stored.list.should.have.length 1

  describe 'Payments.load(options)', () ->
    beforeEach (done) ->
      promises = []
      @data.forEach (payment) ->
        promises.push localforage.setItem(payment.getKey(), payment).then () ->
          # without this, the test is flaky - if keys is called
          # immediately after setItem it sometimes returns an empty list
          new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT))
        Promise.all(promises).then () -> done()

    it 'should return a payments object', () ->
      Payments.load().should.eventually.be.an.instanceof Payments

    it 'should losslessly load a previously saved list of payments for a particular date', () ->
      Payments.load({from: '2013-11-13'}).then (payments) =>
        payments.list.should.have.length 2
        payments.isEquivalent(new Payments @data[1..2]).should.be.true

    it 'should only return uncategorized payments if so requested', () ->
      payment = new Payment @data[0]
      payment.category = "category"
      localforage.setItem(payment.getKey(), payment).then () =>
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT)).then () =>
          Payments.load({categorized: false}).then (payments) =>
            payments.list.should.have.length 3
            payments.isEquivalent(new Payments @data[1..3]).should.be.true

    it 'should only return categorized payments if so requested', () ->
      payment = new Payment @data[0]
      payment.category = "category"
      localforage.setItem(payment.getKey(), payment).then () =>
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT)).then () =>
          Payments.load({categorized: true}).then (payments) =>
            payments.list.should.have.length 1
            payments.isEquivalent(new Payments [payment]).should.be.true

    it 'should only return untagged payments if so requested', () ->
      payment = new Payment @data[0]
      payment.tags = ["tag"]
      localforage.setItem(payment.getKey(), payment).then () =>
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT)).then () =>
          Payments.load({tagged: false}).then (payments) =>
            payments.list.should.have.length 3
            payments.isEquivalent(new Payments @data[1..3]).should.be.true
    it 'should only return tagged payments if so requested', () ->
      payment = new Payment @data[0]
      payment.tags = ["tag"]
      localforage.setItem(payment.getKey(), payment).then () =>
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT)).then () =>
          Payments.load({tagged: true}).then (payments) =>
            payments.list.should.have.length 1
            payments.isEquivalent(new Payments [payment]).should.be.true

      # TODO: write this test, I'm lazy

  describe 'Payments.getCount', () ->
    it 'should return the total number of payments stored', () ->
      payments = new Payments @data
      payments.storeAll().then (response) ->
        # without this, the test is flaky - if keys is called immediately
        # after store it sometimes does not return the full set of keys
        new Promise((resolve, reject) -> setTimeout(resolve, TIMEOUT))
      .then () ->
        Payments.getCount().should.eventually.equal 4

  describe 'Payments.difference(first, second)', () ->
    it 'should return a Payments object containing what is in first but not in second', () ->
      payments1 = new Payments @data
      @data.push @data[0]
      @data.push @data[1]
      payments2 = new Payments @data
      result = Payments.difference(payments2, payments1)
      result.list.should.have.length 2
      result.list.should.include.something.that.deep.equals @data[0]
      result.list.should.include.something.that.deep.equals @data[1]

    it 'should return an empty list if all in first are also in second', () ->
      payments1 = new Payments @data
      @data.push @data[1]
      payments2 = new Payments @data
      result = Payments.difference(payments1, payments2)
      result.list.should.have.length 0

    it 'should return the first list if the second is empty', () ->
      payments = new Payments @data
      Payments.difference(payments, new Payments []).should.deep.equal payments

  describe 'Payments.flatten(list)', () ->
    it 'should return a Payments object containing all Payment in the list of Payments provided', () ->
      payments1 = new Payments @data
      @data.push @data[1]
      payments2 = new Payments @data
      Payments.flatten([payments1, payments2]).list.should.have.length 9
