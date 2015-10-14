Meteor.methods
	registerUser: (formData) ->

		{email, pass, name, inviteKey} = formData

		invitation = email: false
		if inviteKey
			invitation = RocketChat.models.Invitations.findOneByKey inviteKey

		if RocketChat.settings.get 'Invitation_Required'
			unless invitation.email is email
				throw new Meteor.Error 'email-invalid', "Invite doesn't match Email"

		userData =
			email: email
			password: pass

		userId = Accounts.createUser userData

		RocketChat.models.Users.setName userId, name

		if invitation.email
			RocketChat.models.Users.setEmailVerified userId
		else if userData.email
			Accounts.sendVerificationEmail(userId, email)
