FinLabs.models.SKUSetting = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'payment_sku_setting'

		@tryEnsureIndex {'sku': 1}, {'unique': 1}

	# FIND ONE

	findOneById: (_id, options) ->
		query =
			_id: _id

		return @findOne query, options

	findOneBySku: (sku, options) ->
		query =
			sku: sku

		return @findOne query, options


	createOne: (sku, period, extraData) ->
		setting =
			sku: sku
			period: period

		_.extend setting, extraData

		@insert setting

	upsertOne: (sku, period, extraData) ->
		query =
			sku: sku

		setting =
			sku: sku
			period: period

		_.extend setting, extraData

		@upsert query, setting
