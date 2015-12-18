Meteor.methods
	registerUser: (formData) ->
		if RocketChat.settings.get('Accounts_RegistrationForm') is 'Disabled'
			throw new Meteor.Error 'registration-disabled', 'User registration is disabled'

		{email, pass, name, inviteKey} = formData

		invitation = email: false
		if inviteKey
			invitation = RocketChat.models.Invitations.findOneByKey inviteKey

		if RocketChat.settings.get 'Invitation_Required'
			unless invitation.email is email
				throw new Meteor.Error 'email-invalid', "Invite doesn't match Email"

		if RocketChat.settings.get('Accounts_RegistrationForm') is 'Secret URL' and (not formData.secretURL or formData.secretURL isnt RocketChat.settings.get('Accounts_RegistrationForm_SecretURL'))
			throw new Meteor.Error 'registration-disabled', 'User registration is only allowed via Secret URL'

		userData =
			email: email
			password: pass
			invitation: invitation

		userId = Accounts.createUser userData

		RocketChat.models.Users.setName userId, name

		emailEnabled = RocketChat.settings.get('MAIL_URL') or
			(RocketChat.settings.get('SMTP_Host') and
			RocketChat.settings.get('SMTP_Username') and
			RocketChat.settings.get('SMTP_Password'))

		if invitation.email
			RocketChat.models.Users.setEmailVerified userId
		else if userData.email and emailEnabled
			Accounts.sendVerificationEmail(userId, email)

		return userId
