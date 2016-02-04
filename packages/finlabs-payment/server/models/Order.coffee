FinLabs.models.Order = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'payment_orders'

		@tryEnsureIndex { 'orderId': 1 }, { unique: 1 }
		@tryEnsureIndex { 'user': 1 }
		@tryEnsureIndex { 'sku': 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByOrderId: (_id, options) ->
		query =
			orderId: _id

		return @findOne query, options

	findByUser: (_id, options) ->
		query =
			user: _id

		return @find query, options

	findValidByUserAndSKU: (user, sku, options) ->
		query =
			sku: sku
			user: user
			trialEnd:
				$gt: new Date()
			status: 'paid'

		return @find query, options

	# INSERT

	updateByOrderId: (orderId, fields) ->
		fields.updatedAt = new Date()
		query =
			orderId: orderId
		update =
			$set: fields
		return @update query, update

	updateOrAdd: (order, user) ->
		order.orderId = order.id
		delete order.id
		order.updatedAt = new Date()
		order.sku = _.reduce(
			_.findWhere(order.items, type: "sku"),
			(last, value) ->  return last or value,
			undefined
		)
		if user
			order.user = user
		updates = @updateByOrderId order.orderId, order
		if updates
			return updates
		order.createdAt = order.updatedAt
		return @insert order

	# REMOVE
	removeById: (_id) ->
		return @remove _id

	removeByUser: (userId) ->
		return @remove user: userId

	removeByOrderId: (orderId) ->
		return @remove orderId: orderId
