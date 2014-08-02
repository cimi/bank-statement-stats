guid = do ->
  s4 = () ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  () ->
    s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();

formatDate = (date) ->
  moment(date).format('YYYY-MM-DD')

class window.Payment

  constructor: (@date, @name, @ammount, @balance) ->
    @seen = new Date();
    @guid = guid();

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
    Promise.all(promises)

  @load: (from, to) ->
    localforage.keys().then (keys) ->
      console.log keys
      paymentKeys = _.filter keys, (key) -> key.indexOf(keyPrefix) == 0
      promises = []
      _.each paymentKeys, (paymentKey) ->
        promises.push localforage.getItem paymentKey
      Promise.all(promises).then (paymentMap) -> _.flatten(_.map paymentMap, _.values)
