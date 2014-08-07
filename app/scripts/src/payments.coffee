guid = do ->
  s4 = () ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  () ->
    s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();

formatDate = (date) ->
  moment(date).format('YYYY-MM-DD')

dateBetween = (date, start, end) ->
  new Date(start) <= new Date(date) <= new Date(end)

convertStoredPayments = (payments) ->
  _.flatten(_.map payments, _.values).map (payment) ->
    new Payment(payment)

countPayments = (payments) ->
  count = 0
  _.flatten(_.map payments, _.values).length

promisePayments = (keys) ->
  promises = []
  _.each keys, (key) ->
    promises.push localforage.getItem key
  Promise.all(promises)

class window.Payment

  constructor: (options) ->
    {@date, @name, @ammount, @balance, @guid, @seen} = options
    @seen = new Date() if !@seen
    @guid = guid() if !@guid

  isEquivalent: (payment) ->
    equivalent = true
    ['name', 'ammount', 'balance', 'date'].forEach (attribute) =>
      equivalent = false if @[attribute] != payment[attribute]
    equivalent

class window.Payments
  keyPrefix = "payments/"

  constructor: (@paymentList) ->

  @getKey: (item) ->
    keyPrefix + formatDate(item.date)

  store: ->
    groups = _.groupBy @paymentList, 'date'
    promises = []
    _.each groups, (group) =>
      key = @constructor.getKey group[0]
      promises.push localforage.setItem key, group
    Promise.all(promises).then (stored) -> convertStoredPayments stored

  @load: (from, to = from) ->
    predicate = do (from, to) ->
      validPrefix = (key) -> key.indexOf(keyPrefix) == 0
      validDate = (key) -> dateBetween key.replace(keyPrefix, ''), from, to
      if !from || !to then validDate = (key) -> true
      (key) -> validPrefix(key) && validDate(key)
    localforage.keys().then (keys) ->
      filteredKeys = _.filter keys, (key) -> predicate key
      promisePayments(filteredKeys).then (result) -> convertStoredPayments result

  @getCount: () ->
    localforage.keys().then (keys) ->
      promisePayments(keys).then (result) -> countPayments result
