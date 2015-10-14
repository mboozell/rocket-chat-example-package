RocketChat.models.Invitations = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'invitations'

		@tryEnsureIndex { 'key': 1 }, { unique: 1 }
		@tryEnsureIndex { 'email': 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByEmail: (email, options) ->
		query =
			email: email

		return @findOne query, options

	findOneByKey: (key, options) ->
		query =
			key: key

		return @findOne query, options

	findOneByEmailAndKey: (email, key, options) ->
		query =
			email: email
			key: key

		return @findOne query, options

	# INSERT
	createOneWithEmailAndKey: (email, key, extraData) ->
		invitation =
			email: email
			key: key
			ts: new Date()

		_.extend invitation, extraData

		invitation._id = @insert invitation
		return invitation

	createRequest: (email, extraData) ->
		invitation =
			email: email
			ts: new Date()

		_.extend invitation, extraData

		invitation._id = @insert invitation
		return invitation

	# REMOVE
	removeById: (_id) ->
		query =
			_id: _id

		return @remove query

	removeByKey: (key) ->
		query =
			key: key

		return @remove query
