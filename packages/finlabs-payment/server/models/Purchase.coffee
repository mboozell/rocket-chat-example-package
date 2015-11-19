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

	findOneByProduct: (_id, options) ->
		query =
			product: _id

		return @findOne query, options

	findOneByUser: (_id, options) ->
		query =
			user: _id

		return @findOne query, options

	# INSERT

	createOneWithUserAndProduct: (userId, product) ->
		# possibly create a base product id?
		purchase =
			product: product
			user: userId
			active: true
			ts: new Date()

		return @insert purchase

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
