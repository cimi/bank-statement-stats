# global describe, it

describe 'Payment', () ->
  it 'should get a unique guid at creation time', () ->
    payment = new Payment(new Date(), 'Some payment', 100, 2000)
    assert payment.guid.length == 36
    assert payment.guid.split('-').length == 5

createDateString = (date) ->
  moment(date).format('YYYY-MM-DD');

sampleData = [
  new Payment(createDateString(new Date('2013-11-19')), 'Some payment', 100, 0),
  new Payment(createDateString(new Date('2013-11-13')), 'Some payment', 100, 0),
  new Payment(createDateString(new Date('2013-11-13')), 'Some payment', 100, 0),
  new Payment(createDateString(new Date('2013-11-17')), 'Some payment', 100, 0)
]
describe 'Payments', () ->
  it 'should create key for a Payment in the form "payments/<date>"', () ->
    assert Payments.getKey(sampleData[0]) == 'payments/2013-11-19'
    payment = _.clone sampleData[0]
    payment.date = new Date()
    expected = moment(payment.date).format('YYYY-MM-DD')
    assert Payments.getKey(payment) == 'payments/' + expected

  it 'should save a list of payments to localstorage, keyed by date', () ->
    localforage.clear()

    payments = new Payments sampleData
    promise = payments.store()
    promise.then (response) ->
      localforage.getItem 'payments/2013-11-13', (items) ->
        assert items.length == 2
