RocketChat.slashCommands.add 'unmute', null,
	description: TAPi18n.__ 'Unmute_someone_in_room'
	params: '@username'
	filter: () ->
		roomId = Session.get "openedRoom"
		return RocketChat.authz.hasAtLeastOnePermission 'mute-user', roomId
