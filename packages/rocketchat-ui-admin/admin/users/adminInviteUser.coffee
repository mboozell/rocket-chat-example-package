Template.adminInviteUser.helpers
	isAdmin: ->
		return RocketChat.authz.hasRole(Meteor.userId(), 'admin')
	emailEnabled: ->
		return RocketChat.settings.get('MAIL_URL') or
			(RocketChat.settings.get('SMTP_Host') and
			RocketChat.settings.get('SMTP_Username') and
			RocketChat.settings.get('SMTP_Password'))
	inviteEmails: ->
		return Template.instance().inviteEmails.get()
	inviteUrl: ->
		return Template.instance().inviteUrl.get()
	paymentRequired: ->
		RocketChat.settings.get "Require_Payment"
	possibleProductsTemplate: ->
		if FinLabs?.models?.Product then "inviteSubscriptionProducts" else ""
	possibleProductsData: ->
		id: "possible-products-selection"

Template.adminInviteUser.events
	'click .send': (e, instance) ->
		values = $('#inviteEmails').val().split /[,;]/
		validEmails = _.compact _.map values, (val) ->
		  parts = _.compact val.split(/\s/)
		  email = parts.pop()
		  name = parts.join(' ')
		  return [name, email] if instance.isValidEmail(email)
		if validEmails.length
				Meteor.call 'sendInvitationEmail', validEmails, (error, result) ->
					if result
						instance.clearEmailForm()
						successfulEmails = _.map result, (tuple) ->
							[name, email] = tuple
							return if name then name + " at " + email else email
						instance.inviteEmails.set successfulEmails
					if error
						toastr.error error.reason
			else
				toastr.error t('Send_invitation_email_error')

	'click .cancel': (e, instance) ->
		instance.clearEmailForm()
		instance.inviteEmails.set []
		RocketChat.TabBar.closeFlex()

	'click .generate': (e, instance) ->
		email = $('#inviteEmail').val()
		options =
			name: $('#inviteName').val()
			overrideProducts: instance.generateProductList

		if not instance.isValidEmail(email)
			toastr.error t("Email not valid")
		else
			Meteor.call 'createInvitation', email, options, (error, result) ->
				if result
					instance.inviteUrl.set(result.url)
					instance.clearGenerateForm()
				if error
					toastr.error error.reason

	'keyup #inviteEmail, keyup #inviteName': (e, instance) ->
		instance.inviteUrl.set('')

	'productListChange #possible-products-selection': (e, t, v) ->
		productList = v.data
		t.generateProductList = _.map productList, (product) -> product._id

Template.adminInviteUser.onCreated ->
	@inviteEmails = new ReactiveVar []
	@inviteUrl = new ReactiveVar ''
	@generateProductList = []
	@clearEmailForm = ->
		$('#inviteEmails').val('')
	@clearGenerateForm = ->
		$('#inviteEmail').val('')
		$('#inviteName').val('')
	@isValidEmail = (email) ->
		rfcMailPattern = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
		return rfcMailPattern.test(email)
