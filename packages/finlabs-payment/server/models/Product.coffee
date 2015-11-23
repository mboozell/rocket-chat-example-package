FinLabs.models.Product = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'payment_product'

		@tryEnsureIndex {'name': 1}, {'unique': 1}
		@tryEnsureIndex {'apiKey': 1}, {'unique': 1}

	# FIND ONE

	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByKey: (key, options) ->
		query =
			apiKey: key

		return @findOne query, options

	findBase: (options) ->
		query =
			baseProduct: true

		return @find query, options

	findByPaymentType: (type, options) ->
		query =
			payments:
				$elemMatch:
					type: type

		return @find query, options

	# INSERT

	createOne: (name, roles, channels, payments, options) ->
		product =
			name: name
			roles: roles
			channels: channels
			payments: payments
			apiKey: Random.secret()
			ts: new Date()

		_.extend product, options

		return @insert product

	addOrUpdate: (name, roles, channels, payments, options) ->
		product =
			name: name
			roles: roles
			channels: channels
			payments: payments
			apiKey: Random.secret()
			ts: new Date()

		_.extend product, options

		return @upsert name: name, product

	# UPDATE

	updatePlan: (plan) ->
		query =
			payments:
				$elemMatch:
					"plan.id": plan.id
		update =
			$set:
				"payments.$.plan.amount": plan.amount
				"payments.$.plan.trialDays": plan.trial_period_days
				"payments.$.plan.interval": plan.interval

		return @update query, update

