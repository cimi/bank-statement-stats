# global describe, it

describe 'Payment', () ->
  it 'should get a unique ', () ->
    payment = new Payment(new Date(), "Some payment", 100, 2000)

