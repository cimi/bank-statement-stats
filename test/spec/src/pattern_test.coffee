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
    name: 'XXX payment',
    ammount: 100,
    balance: 0
  })

]


describe "Pattern", () ->
  describe 'constructor(regex, category, tags)', () ->
    it 'should store regex, category and tags passed in at construction time', () ->
      pattern = new Pattern(/regex/, "category", ["tag1", "tag2"])
      pattern.regex.toString().should.equal /regex/.toString()
      pattern.category.should.equal "category"
      pattern.tags.should.deep.equal ["tag1", "tag2"]

  describe 'categorize(Payments)', () ->
    it 'should add the category and tags on the payments whose name matches the regex', () ->
      pattern = new Pattern(/Some .*/, "category", ["tag1", "tag2"])
      payments = new Payments(sampleData)
      categorized = pattern.categorize(payments)
      categorized.list[0].category.should.equal "category"
      categorized.list[1].category.should.equal "category"
      categorized.list[2].category.should.equal ""
      categorized.list[0].tags.should.deep.equal ["tag1", "tag2"]
      categorized.list[1].tags.should.deep.equal ["tag1", "tag2"]
      categorized.list[2].tags.should.deep.equal []

    it 'should not change the initial collection provided, it should return a new one', () ->
      pattern = new Pattern(/Some .*/, "category", ["tag1", "tag2"])
      payments = new Payments(sampleData)
      categorized = pattern.categorize(payments)
      payments.list[0].category.should.equal ''
      payments.list[0].tags.should.deep.equal []

