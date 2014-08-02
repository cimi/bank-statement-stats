guid = do ->
  s4 = () ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  () ->
    s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();

class window.Payment
  constructor: (@date, @name, @ammount, @balance) ->
    @seen = new Date();
    @guid = guid();

class window.Payments
  constructor: (@paymentList) ->

  @getKey: (item) ->
    'payments/' + item.date

  store: ->
    groups = _.groupBy @paymentList, 'date'
    promises = []
    _.each groups, (group) =>
      key = @constructor.getKey group[0]
      promises.push localforage.setItem key, group
    Promise.all(promises)
