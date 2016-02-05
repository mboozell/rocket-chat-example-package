FinLabs.slashAlert.models.Alert = new class extends RocketChat.models._Base
	constructor: ->
		@_initModel 'slashcommand_alert'

		@tryEnsureIndex { 'room': 1 }
		@tryEnsureIndex { 'user': 1 }
		@tryEnsureIndex { 'ts': 1 }


	# FIND ONE
	findOneByRoomIdAndUserId: (roomId, userId) ->
		query =
			room: roomId
			user: userId

		return @findOne query

	# FIND
	findByUserId: (userId, options) ->
		query =
			user: userId

		return @find query, options

	findByRoomId: (roomId, options) ->
		query =
			room: roomId

		return @find query, options

	findAfterTime: (ts, options) ->
		query =
			ts: $gt: ts

		return @find query, options

	findAfterTimeInRooms: (ts, rids, options) ->
		query =
			ts:
				$gt: ts
			room:
				$in: rids

		return @find query, options


	# INSERT
	createWithRoomAndUser: (roomId, userId, extraData) ->
		subscription =
			ts: new Date
			room: roomId
			user: userId

		_.extend subscription, extraData

		return @insert subscription


	# REMOVE
	removeByUserId: (userId) ->
		query =
			user: userId

		return @remove query

	removeByRoomId: (roomId) ->
		query =
			room: roomId

		return @remove query

	removeByRoomIdAndUserId: (roomId, userId) ->
		query =
			room: roomId
			user: userId

		return @remove query

