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
			key: key

		return @findOne query, options

	findBase: (options) ->
		query =
			baseProduct: true

		return @find query, options

	# INSERT

	createOne: (name, roles = [], channels = [], payments = [], options = {}) ->
		product =
			name: name
			roles: roles
			channels: roles
			payments: payments
			ts: new Date()

		_.assign product, options

		return @insert product

	createOneBase: (name, roles = [], channels = [], payments = [], options = {}) ->
		_.assign options, baseProduct: true
		@createOne name, roles, channels, payments, options

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

