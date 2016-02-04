FinLabs.lib.emailInvite = (invitation) ->
	template = "invitationEmail"
	data = url: invitation.url
	settings =
		subject: RocketChat.settings.get 'Invitation_Subject'
	to = invitation.email

	FinLabs.lib.emailTemplate template, to, data, settings

	FinLabs.lib.emailAdminsUpdate
		subject: "Chat Update! New Invite Sent"
		text: "Sent #{invitation.email} an invite with url #{invitation.url}"

	return sent
