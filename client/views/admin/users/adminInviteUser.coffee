Template.adminInviteUser.helpers
	isAdmin: ->
		return RocketChat.authz.hasRole(Meteor.userId(), 'admin')
	emailEnabled: ->
		console.log 'emailEnabled', RocketChat.settings.get('MAIL_URL') or (RocketChat.settings.get('SMTP_Host') and RocketChat.settings.get('SMTP_Username') and RocketChat.settings.get('SMTP_Password'))
		return RocketChat.settings.get('MAIL_URL') or (RocketChat.settings.get('SMTP_Host') and RocketChat.settings.get('SMTP_Username') and RocketChat.settings.get('SMTP_Password'))
	inviteEmails: ->
		return Template.instance().inviteEmails.get()

Template.adminInviteUser.events
	'click .send': (e, instance) ->
		values = $('#inviteEmails').val().split /[,;]/
		rfcMailPattern = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
		validEmails = _.compact _.map values, (val) ->
		  parts = _.compact val.split(/\s/)
		  email = parts.pop()
		  name = parts.join(' ')
		  return [name, email] if rfcMailPattern.test email
		if validEmails.length
				Meteor.call 'sendInvitationEmail', validEmails, (error, result) ->
					if result
						instance.clearForm()
						successfulEmails = _.map result, (tuple) ->
							[name, email] = tuple
							return if name then name + " at " + email else email
						instance.inviteEmails.set successfulEmails
					if error
						toastr.error error.reason
			else
				toastr.error t('Send_invitation_email_error')

	'click .cancel': (e, instance) ->
		instance.clearForm()
		instance.inviteEmails.set []
		RocketChat.TabBar.closeFlex()

Template.adminInviteUser.onCreated ->
	@inviteEmails = new ReactiveVar []
	@clearForm = ->
		$('#inviteEmails').val('')
