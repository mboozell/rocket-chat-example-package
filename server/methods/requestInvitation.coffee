Meteor.methods
	requestInvitation: (email) ->

		rfcMailPattern = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

		if not rfcMailPattern.test email
			throw new Meteor.Error 'email-invalid'

		console.log '[methods] requestInvitation -> '.green, 'arguments:', arguments

		# create new room
		invitation = RocketChat.models.Invitations.createRequest email

		return success: true
