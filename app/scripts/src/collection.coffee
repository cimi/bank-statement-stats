class window.Collection
  constructor: (list) ->
    throw "Collection must be created from an array, received " + list if !(list instanceof Array)
    @list = _.clone list
    types = @list.map (item) -> item.constructor.name
    throw "Models are not of the same type, seen " + types if _.uniq(types).length > 1

  store: ->
    promises = []
    @list.forEach (element) ->
      hasStoreMethod = typeof element.store == "function"
      throw "Model object " + element.constructor.name + " does not have a store method" if !hasStoreMethod
      promises.push element.store()
    Promise.all(promises).then (list) -> new Collection list

