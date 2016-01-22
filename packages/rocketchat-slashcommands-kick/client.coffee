RocketChat.slashCommands.add 'kick', (command, params, item) ->
	username = params.trim()
	if username is ''
		return
	username = username.replace('@', '')

	if Session.get('showUserInfo') is username
		Session.set('showUserInfo', null)
,
	description: TAPi18n.__ 'Remove_someone_from_room'
	params: '@username'
	filter: () ->
		roomId = Session.get "openedRoom"
		return RocketChat.authz.hasAtLeastOnePermission 'remove-user', roomId
