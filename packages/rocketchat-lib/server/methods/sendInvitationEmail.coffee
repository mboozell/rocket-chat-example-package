Meteor.methods
	sendInvitationEmail: (emails) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] sendInvitationEmail -> Invalid user"

		unless RocketChat.authz.hasRole(Meteor.userId(), 'admin')
			throw new Meteor.Error 'not-authorized', '[methods] sendInvitationEmail -> Not authorized'

		rfcMailPattern = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
		validTuples = _.compact _.map emails, (tuple) ->
			return false unless tuple.length
			name = tuple[0]
			email = tuple[tuple.length-1]
			return [name, email] if rfcMailPattern.test email

		for tuple in validTuples
			@unblock()

			name = tuple[0]
			email = tuple[tuple.length-1]
			names = name.split /\s/
			firstName = names[0]
			lastName = names[names.length-1]

			{url} = Meteor.call 'createInvitation', email, name

			html = RocketChat.settings.get 'Invitation_HTML'
			html = html.replace "{{url}}", url
			html = html.replace "{{name}}", name
			html = html.replace "{{firstName}}", firstName
			html = html.replace "{{lastName}}", lastName

			Email.send
				to: email
				from: RocketChat.settings.get 'From_Email'
				subject: RocketChat.settings.get 'Invitation_Subject'
				html: html

		return validTuples
