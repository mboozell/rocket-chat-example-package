FinLabs.models.WiseGuyAlerts = new class extends RocketChat.models._Base
  constructor: ->
    @_initModel 'wiseguy_alerts'

    @tryEnsureIndex { 'apiKey': 1 }
    @tryEnsureIndex { 'ticker': 1 }


  # FIND ONE
  findOneById: (_id, options) ->
    query =
      _id: _id

    return @findOne query, options


  # INSERT
  createOneWithApiKey: (alert, key, extraData) ->
    alert.ts = new Date()
    alert.key = key

    _.extend alert, extraData

    alert._id = @insert alert
    return alert

  # REMOVE
  removeById: (_id) ->
    query =
      _id: _id

    return @remove query