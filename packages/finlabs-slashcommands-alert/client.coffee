RocketChat.slashCommands.add 'alert', undefined,
	description: TAPi18n.__ 'Alert_channel_of_important_information'
	params: 'message'
	filter: () ->
		roomId = Session.get "openedRoom"
		return RocketChat.authz.hasAtLeastOnePermission 'alert-room', roomId

FinLabs.slashAlert.stream.on 'new-alert', (data) ->
	console.log data
