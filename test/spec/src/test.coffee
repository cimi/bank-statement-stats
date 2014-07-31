# global describe, it

describe 'Payment', () ->
  it 'should get a unique guid at creation time', () ->
    payment = new Payment(new Date(), "Some payment", 100, 2000)
    console.log(payment.guid)
    assert payment.guid.length == 36
    assert payment.guid.split("-").length == 5
