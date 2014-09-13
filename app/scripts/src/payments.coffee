guid = do ->
  s4 = () ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  () ->
    s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();

formatDate = (date) ->
  moment(date).format('YYYY-MM-DD')

dateBetween = (date, start, end) ->
  new Date(start) <= new Date(date) <= new Date(end)

keyPrefix = 'payments/'

class window.Payment
  constructor: (options) ->
    {@date, @name, @ammount, @balance, @guid, @seen, @category, @tags} = options
    @guid = guid() if !@guid
    @category = '' if !@category
    @tags = [] if !@tags

  isEquivalent: (payment) ->
    equivalent = true
    ['name', 'ammount', 'balance', 'date'].forEach (attribute) =>
      equivalent = false if @[attribute] != payment[attribute]
    equivalent

  hashDetails: () ->
    details = ''
    ['name', 'ammount', 'balance', 'date'].forEach (detail) =>
      details += @[detail]
    sha1(details)

  getKey: () ->
    keyPrefix + formatDate(@date) + '/' + @guid

  store: () ->
    localforage.setItem(@getKey(), @).then (obj) -> new Payment obj


class window.Payments

  promisePayments = (keys) ->
    promises = []
    _.each keys, (key) ->
      promises.push localforage.getItem(key).then (obj) -> new Payment obj
    Promise.all(promises).then (list) -> new Payments list

  constructor: (list) -> @list = _.clone(list)

  clone: () -> new Payments @list.map (payment) -> new Payment(payment)

  isEquivalent: (other) ->
    equivalent = true
    ours = _.sortBy @list, 'guid'
    theirs = _.sortBy other.list, 'guid'
    return false if ours.length != theirs.length
    ours.forEach (val, idx) ->
      equivalent = false if not ours[idx].isEquivalent(theirs[idx])
    equivalent

  storeAll: ->
    promises = []
    @list.forEach (payment) ->
      promises.push payment.store()
    Promise.all(promises).then (list) -> new Payments list

  storeDiff: ->
    groups = _.groupBy @list, 'date'
    promises = []
    _.each groups, (group, date) =>
      current = new Payments group
      promise = @constructor.load {from: date}
      promises.push promise.then (previous) =>
        @constructor.difference(current, previous).storeAll()
    Promise.all(promises).then (stored) => @constructor.flatten(stored)

  @difference: (payments1, payments2) ->
    group = (payments) ->
      _.groupBy payments.list, (payment) -> payment.hashDetails()
    payments1 = group(payments1)
    payments2 = group(payments2)
    _.each payments1, (payments, hash) ->
      if payments2[hash]
        payments1[hash] = _.rest payments1[hash], payments2[hash].length
    result = []
    _.each payments1, (payments) ->
      result.push payments
    new Payments _.flatten result

  @load: (options) ->
    {from, to, categorized, tagged} = options if options
    to = from if !to
    predicate = do (from, to) ->
      validPrefix = (key) -> key.indexOf(keyPrefix) == 0
      validDate = (key) ->
        if !from || !to then true else dateBetween key.split('/')[1], from, to
      (key) -> validPrefix(key) && validDate(key)
    localforage.keys().then (keys) ->
      filteredKeys = _.filter keys, (key) -> predicate key
      promisePayments(filteredKeys).then (payments) -> new Payments payments.list.filter (payment) ->
        categoryFilter = (payment) ->
          if categorized != undefined then categorized == (payment.category != '') else true
        tagFilter = (payment) ->
          if tagged != undefined then tagged == (payment.tags.length >= 1) else true
        categoryFilter(payment) && tagFilter(payment)


  @getCount: () ->
    localforage.keys().then (keys) ->
      keys = _.filter keys, (key) -> key.indexOf(keyPrefix) == 0
      promisePayments(keys).then (result) -> result.list.length

  @flatten: (list) ->
    result = []
    list.forEach (payments) -> result = result.concat(payments.list)
    new Payments result
