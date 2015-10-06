Meteor.methods
	sendIntegrationMessage: (message, key, options	) ->

		console.log(message)
		unless message and message.msg and message.rid
			throw new Meteor.Error 500, '[methods] sendIntegrationMessage -> Not valid message'

		integration = RocketChat.models.Integrations.findOneByKey(key)

		if not integration
			throw new Meteor.Error 401, '[methods] sendIntegrationMessage -> Not Authorized'

		options = options || {}
		options.integration = true

		room = RocketChat.models.Rooms.findOneById(message.rid)

		if not room
			throw new Meteor.Error 500, '[methods] sendIntegrationMessage -> Not valid room'

		RocketChat.sendMessage integration, message, room, options
