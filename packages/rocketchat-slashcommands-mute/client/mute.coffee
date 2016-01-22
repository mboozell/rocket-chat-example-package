RocketChat.slashCommands.add 'mute', null,
	description: TAPi18n.__ 'Mute_someone_in_room'
	params: '@username'
	filter: () ->
		roomId = Session.get "openedRoom"
		return RocketChat.authz.hasAtLeastOnePermission 'mute-user', roomId
