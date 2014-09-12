describe "Pattern", () ->
  describe 'constructor(regex)', () ->
    it 'should store a regex object passed in at construction time', () ->
      pattern = new Pattern(/regex/)
      pattern.regex.toString().should.equal /regex/.toString()

