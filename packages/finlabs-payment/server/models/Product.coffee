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

	# INSERT

	createOne: (name, roles, payments, options) ->
		product =
			name: name
			roles: roles
			payments: payments
			ts: new Date()

		_.assign product, options

		return @insert product
