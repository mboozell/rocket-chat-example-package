###
# alert is a named function that will replace /invite commands
# @param {Object} message - The message object
###

class Alert
	constructor: (command, params, item) ->
		if command isnt 'alert' or not Match.test params, String
			return

		unless RocketChat.authz.hasPermission Meteor.userId(), 'alert-room', item.rid
			return

		user = Meteor.user()
		room = RocketChat.models.Rooms.findOneById item.rid

		unless room
			return

		msg = if params.trim().length > 0 then params.trim() else false
		message = msg: msg, alert: true

		RocketChat.sendMessage user, message, room
		FinLabs.slashAlert.models.Alert.createWithRoomAndUser room._id, user._id


RocketChat.slashCommands.add 'alert', Alert

FinLabs.slashAlert.stream.permissions.write -> false
FinLabs.slashAlert.stream.permissions.read -> true
