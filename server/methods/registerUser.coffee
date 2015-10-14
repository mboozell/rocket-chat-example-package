Meteor.methods
	registerUser: (formData) ->

		if RocketChat.settings.get 'Invitation_Required'
			key = formData.inviteKey
			invitation = if key then RocketChat.models.Invitations.findOneByKey key else {email: false}
			unless invitation.email is formData.email
				throw new Meteor.Error 'email-invalid', "Invite doesn't match Email"


		userData =
			email: formData.email
			password: formData.pass

		userId = Accounts.createUser userData

		RocketChat.models.Users.setName userId, formData.name

		if userData.email
			Accounts.sendVerificationEmail(userId, userData.email)
