RocketChat.slashCommands.add 'invite', undefined,
	description: TAPi18n.__ 'Invite_user_to_join_channel'
	params: '@username'
	filter: () ->
		roomId = Session.get "openedRoom"
		return RocketChat.authz.hasAtLeastOnePermission 'add-user', roomId
