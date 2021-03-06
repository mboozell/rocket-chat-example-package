Meteor.methods
	createInvitation: (email, options) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createInvitation -> Invalid user"

		rfcMailPattern = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

		if not rfcMailPattern.test email
			throw new Meteor.Error 'email-invalid'

		if RocketChat.authz.hasPermission(Meteor.userId(), 'create-invitation') isnt true
			throw new Meteor.Error 'not-authorized', '[methods] createInvitation -> Not authorized'

		console.log '[methods] createInvitation -> '.green,
			'userId:', Meteor.userId(), 'arguments:', arguments

		# create new room
		invitation = RocketChat.models.Invitations.createOneWithEmail email, options
		invitation.url = "#{Meteor.absoluteUrl()}register?invite=#{encodeURIComponent(invitation.key)}"

		return invitation
