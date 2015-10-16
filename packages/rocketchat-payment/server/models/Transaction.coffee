RocketChat.models.Transaction = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'transactions'

		@tryEnsureIndex { 'transactionId': 1 }, { unique: 1 }
		@tryEnsureIndex { 'user': 1 }
		@tryEnsureIndex { 'customer': 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByTransactionId: (_id, options) ->
		query =
			transactionId: _id

		return @findOne query, options

	findOneByUser: (_id, options) ->
		query =
			user: _id

		return @findOne query, options

	findOneByCustomer: (_id, options) ->
		query =
			customer: _id

		return @findOne query, options

	# INSERT

	createFromStripe: (userId, charge) ->
		charge.transactionId = charge.id
		delete charge.id
		charge.user = userId
		return @insert charge

	# REMOVE
	removeById: (_id) ->
		return @remove _id
