fs = Npm.require('fs')

FinLabs.lib.emailTemplate = (template, to, data = {}, settings = {}) ->
	templateUrl = "./assets/app/templates/#{template}.html"
	html = fs.readFileSync templateUrl, 'utf8'

	for key, value of data
		html = html.replace "{{#{key}}}", value

	email =
		to: to
		from: RocketChat.settings.get 'From_Email'
		html: html

	_.extend email, settings

	tries = 0
	sent = false
	while true
		try
			sent = Email.send email
			break
		catch e
			if tries < 3
				tries++
			else
				throw e

	return sent

