FinLabs.models.Tool = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'payment_tool'

		@tryEnsureIndex {'name': 1}, {'unique': 1}

	# FIND ONE

	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByName: (name, options) ->
		query =
			name: name

		return @findOne query, options


	createOneWithRoles: (name, roles, extraData) ->
		tool =
			name: name
			roles: roles

		_.extend tool, extraData

		@insert tool

	upsertOneWithRoles: (name, roles, extraData) ->
		query =
			name: name

		tool =
			name: name
			roles: roles

		_.extend tool, extraData

		@upsert query, tool
