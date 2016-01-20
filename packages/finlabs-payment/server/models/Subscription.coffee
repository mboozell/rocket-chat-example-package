FinLabs.models.Subscription = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'payment_subscriptions'

		@tryEnsureIndex { 'subscriptionId': 1 }, { unique: 1 }
		@tryEnsureIndex { 'user': 1 }
		@tryEnsureIndex { 'customer': 1 }


	# FIND ONE
	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneBySubscriptionId: (_id, options) ->
		query =
			subscriptionId: _id

		return @findOne query, options

	findOneByUser: (_id, options) ->
		query =
			user: _id

		return @findOne query, options

	findOneByCustomer: (_id, options) ->
		query =
			customer: _id

		return @findOne query, options

	findActiveByUserAndPlan: (userId, planId) ->
		now = Date.now()
		query =
			user: userId
			current_period_end: { $lte: now }
			"plan.id": planId

		@find query

	userHasActivePlan: (userId, planId) ->
		@findActiveByUserAndPlan(userId, planId).count() > 0

	# INSERT

	createFromStripe: (userId, subscription) ->
		subscription.subscriptionId = subscription.id
		delete subscription.id
		subscription.user = userId
		return @insert subscription

	updateBySubscriptionId: (subscriptionId, fields) ->
		fields.updatedAt = new Date()
		query =
			subscriptionId: subscriptionId
		update =
			$set: fields
		return @update query, update

	updateOrAdd: (subscription) ->
		subscription.subscriptionId = subscription.id
		subscription.updatedAt = new Date()
		delete subscription.id
		updates = @updateBySubscriptionId subscription.subscriptionId, subscription
		if updates
			console.log "Updated #{updates} documents"
			return updates
		subscription.createdAt = subscription.updatedAt
		customer = FinLabs.models.Customer.findOneByCustomerId subscription.customer
		subscription.user = customer.user
		return @insert subscription

	# REMOVE
	removeById: (_id) ->
		return @remove _id

	removeByUser: (userId) ->
		return @remove user: userId
