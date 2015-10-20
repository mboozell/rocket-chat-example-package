RocketChat.models.Customer = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'customers'

		@tryEnsureIndex { 'user': 1 }, { unique: 1 }
		@tryEnsureIndex { 'customerId': 1 }, { unique: 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByUser: (_id, options) ->
		query =
			user: _id

		return @findOne query, options

	findOneByCustomerId: (_id, options) ->
		query =
			customerId: _id

		return @findOne query, options

	# INSERT
	create: (data) ->
		customer =
			createdAt: new Date

		_.extend customer, data

		return @insert customer

	createWithUserAndCustomerId: (user, customerId) ->
		data =
			user: user
			customerId: customerId

		return @create data


	# REMOVE
	removeById: (_id) ->
		return @remove _id
