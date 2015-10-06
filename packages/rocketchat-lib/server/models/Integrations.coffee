RocketChat.models.Integrations = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'integrations'

		@tryEnsureIndex { 'key': 1 }, { unique: 1 }
		@tryEnsureIndex { 'name': 1 }, { unique: 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByName: (name, options) ->
		query =
			name: name

		return @findOne query, options

	findOneByKey: (key, options) ->
		query =
			key: key

		return @findOne query, options

	# INSERT
	createOneWithApiKey: (name, key, extraData) ->
		integration =
			name: name
			key: key
			ts: new Date()

		_.extend integration, extraData

		integration._id = @insert integration
		return integration

	# REMOVE
	removeById: (_id) ->
		query =
			_id: _id

		return @remove query

	removeByName: (name) ->
		query =
			name: name

		return @remove query
