fs = Npm.require('fs')

FinLabs.payment.addAndSendInvitation = (email, stripe, apiKey) ->
	unless email
		throw new Meteor.Error 500, 'Invalid Invitation'

	product = FinLabs.models.Product.findOneByKey(apiKey)

	if not product
		throw new Meteor.Error 401, 'Bad API Key -> Not Authorized'

	invitation = RocketChat.models.Invitations.createOneWithEmail email, stripe: stripe
	invitation.url = "#{Meteor.absoluteUrl()}register?invite=#{encodeURIComponent(invitation.key)}"

	if RocketChat.models.Users.findOneByEmailAddress email
		user = RocketChat.models.Users.findOneByEmailAddress email
		FinLabs.updateUserFromInvitation user, invitation
		invitation.url = "#{Meteor.absoluteUrl()}"

	invitationHtml = fs.readFileSync './assets/app/templates/invitationEmail.html', 'utf8'
	invitationHtml = invitationHtml.replace '{{url}}', invitation.url

	email =
		to: invitation.email
		from: RocketChat.settings.get 'From_Email'
		subject: RocketChat.settings.get 'Invitation_Subject'
		html: invitationHtml

	tries = 0
	while true
		try
			return Email.send email
		catch e
			if tries < 3
				tries++
			else
				throw e
