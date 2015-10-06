Meteor.methods
	sendIntegrationMessage: (rid, msg, key, options) ->

		integration = RocketChat.models.Integrations.findOneByKey(key)

		if not integration
			throw new Meteor.Error 401, '[methods] sendIntegrationMessage -> Not Authorized'
