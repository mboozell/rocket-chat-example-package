FinLabs.lib.emailAdminsUpdate = (settings) ->
	Meteor.defer ->
		emailString = RocketChat.settings.get 'Admin_Emails'
		unless emailString?.length
			return
		emails = emailString.split(',').map (email) -> email.trim()

		email =
			to: emails
			from: RocketChat.settings.get 'From_Email'
			subject: "Update From the Chat!"

		_.extend email, settings

		tries = 0
		while true
			try
				return Email.send email
			catch e
				if tries < 3
					tries++
				else
					throw e

