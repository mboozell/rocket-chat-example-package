FinLabs.models.Purchase = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'payment_purchase'

		@tryEnsureIndex { 'product': 1 }
		@tryEnsureIndex { 'user': 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findAllByProduct: (_id, options) ->
		query =
			product: _id

		return @find query, options

	findAllByUser: (_id, options) ->
		query =
			user: _id

		return @find query, options

	findAllWithUserAndProduct: (userId, productId, options) ->
		query =
			user: userId
			product: productId

		return @find query, options

	# INSERT

	createActive: (userId, productId) ->
		query =
			user: userId
			product: productId

		purchase =
			product: productId
			user: userId
			active: true
			ts: new Date()

		return @upsert query, purchase

	createInactive: (userId, productId) ->
		query =
			user: userId
			product: productId

		purchase =
			product: productId
			user: userId
			active: false
			ts: new Date()

		return @upsert query, purchase

	# UPDATE

	makeActive: (_id) ->
		query =
			_id: _id

		update =
			$set: active: true

		return @update query, update


	makeInactive: (_id) ->
		query =
			_id: _id

		update =
			$set: active: false

		return @update query, update

	# REMOVE
	removeById: (_id) ->
		return @remove _id
