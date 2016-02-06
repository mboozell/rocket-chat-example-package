FinLabs.hftAlert.models.Meta = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'hftalert_meta'

	create: (id) ->
		query =
			_id: id

		doc =
			_id: id
			locked: false
			updated: new Date()

		@upsert query, doc

	findByIds: (ids, options) ->
		query =
			_id: $in: ids

		@find query, options

	setLocked: (id, locked) ->
		query =
			_id: id

		update =
			locked: locked
			updated: new Date()

		@update query, update

	isLocked: (id) ->
		doc = @findOne _id: id
		if doc.locked
			if (new Date() - doc.updated) < 1000
				return false
		return true
