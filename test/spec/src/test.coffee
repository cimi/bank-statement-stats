# global describe, it

describe 'Payment', () ->
  it 'should get a unique guid at creation time', () ->
    payment = new Payment(new Date(), 'Some payment', 100, 2000)
    assert payment.guid.length == 36
    assert payment.guid.split('-').length == 5

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
describe 'Payments', () ->

  beforeEach (done) ->
    localforage.clear().then () -> done()

  it 'should create key for a Payment in the form "payments/<date>"', () ->
    assert Payments.getKey(sampleData[0]) == 'payments/2013-11-19'
    payment = _.clone sampleData[0]
    payment.date = new Date()
    expected = moment(payment.date).format('YYYY-MM-DD')
    assert Payments.getKey(payment) == 'payments/' + expected

  it 'should save a list of payments to localstorage, keyed by date', () ->
    payments = new Payments sampleData
    payments.store().then (response) ->
      localforage.getItem('payments/2013-11-13').should.eventually.have.length 2

  it 'should losslessly load a previously saved list of payments', () ->
    localforage.setItem('payments/2013-11-13', sampleData[1..2]).then () ->
      # without this, the test is flaky - if keys is called
      # immediately after setItem it sometimes returns an empty list
      new Promise((resolve, reject) -> setTimeout(resolve, 20))
    .then () ->
        payments = Payments.load('2013-11-13')
        payments.should.eventually.have.length 2
        payments.should.eventually.deep.equal sampleData[1..2]

  it 'should return the total number of payments stored', () ->
    payments = new Payments sampleData
    payments.store().then (response) ->
      # without this, the test is flaky - if keys is called immediately
      # after store it sometimes does not return the full set of keys
      new Promise((resolve, reject) -> setTimeout(resolve, 20))
    .then () ->
      Payments.getCount().should.eventually.equal 4
