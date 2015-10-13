Meteor.methods
	createInvitation: (email, name) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createInvitation -> Invalid user"
			
		console.log email, name

		if not /^[^@]+@[^@]+\.[^@]+$/.test email
			throw new Meteor.Error 'email-invalid'

		if RocketChat.authz.hasPermission(Meteor.userId(), 'create-invitation') isnt true
			throw new Meteor.Error 'not-authorized', '[methods] createInvitation -> Not authorized'

		console.log '[methods] createInvitation -> '.green,
			'userId:', Meteor.userId(), 'arguments:', arguments

		key = Random.secret()

		options = {}
		if name
			options.name = name

		# create new room
		invitation = RocketChat.models.Invitations.createOneWithEmailAndKey email, key, options

		return {
			iid: invitation._id
		}
