###
# Leave is a named function that will replace /leave commands
# @param {Object} message - The message object
###

if Meteor.isClient
	RocketChat.slashCommands.add 'hide', undefined,
		description: 'Hide the current channel'
		params: ''

else
	class Hide
		constructor: (command, params, item) ->
			if(command == "hide")
				Meteor.call 'hideRoom', item.rid

	RocketChat.slashCommands.add 'hide', Hide
