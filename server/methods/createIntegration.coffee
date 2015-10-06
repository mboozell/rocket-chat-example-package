Meteor.methods
	createIntegration: (name) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createIntegration -> Invalid user"

		if not /^[0-9a-zA-Z-_]+$/.test name
			throw new Meteor.Error 'name-invalid'

		if RocketChat.authz.hasPermission(Meteor.userId(), 'create-integration') isnt true
			throw new Meteor.Error 'not-authorized', '[methods] createIntegration -> Not authorized'

		console.log '[methods] createIntegration -> '.green,
			'userId:', Meteor.userId(), 'arguments:', arguments

		# avoid duplicate names
		if RocketChat.models.Integrations.findOneByName name
			throw new Meteor.Error 'duplicate-integration'

		key = Random.secret()
		console.log(key)

		# create new room
		integration = RocketChat.models.Integrations.createOneWithApiKey name, key

		return {
			iid: integration._id
		}
