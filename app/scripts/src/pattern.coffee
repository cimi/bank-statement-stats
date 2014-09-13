class window.Pattern
  constructor: (@regex, @category, @tags) ->

  categorize: (payments) ->
    cloned = payments.clone()
    cloned.list.forEach (payment) =>
      if @regex.test payment.name
        payment.category = @category
        payment.tags = @tags
    cloned


