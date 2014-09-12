class window.Collection
  constructor: (list) -> @list = _.clone list

  store: ->
    promises = []
    @list.forEach (element) ->
      promises.push element.store()
    Promise.all(promises).then (list) -> new Collection list

