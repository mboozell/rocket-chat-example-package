RocketChat.slashCommands.add 'join', undefined,
	description: TAPi18n.__ 'Join_the_given_channel'
	params: '#channel'
	filter: () ->
		return RocketChat.settings.get 'General_Channels_Enabled'
