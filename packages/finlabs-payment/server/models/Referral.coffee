FinLabs.models.Referral = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'payment_referral'

		@tryEnsureIndex {'user': 1}
		@tryEnsureIndex {'product': 1}

	# FIND ONE

	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneByUser: (userId, options) ->
		query =
			user: userId

		return @findOne query, options

	# INSERT

	createOne: (userId, productId, options) ->
		referral =
			user: userId
			product: productId

		_.extend referral, options

		return @insert referral

	removeByUser: (userId) ->
		return @remove user: userId
