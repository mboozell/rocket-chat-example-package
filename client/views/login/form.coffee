Template.loginForm.helpers
	userName: ->
		return Meteor.user()?.username

	namePlaceholder: ->
		return if RocketChat.settings.get 'Accounts_RequireNameForSignUp' then t('Name') else t('Name_optional')

	showName: ->
		Template.instance().showFieldWhen 'register'

	showPassword: ->
		Template.instance().showFieldWhen ['login', 'register']

	showConfirmPassword: ->
		Template.instance().showFieldWhen 'register'

	showEmailOrUsername: ->
		Template.instance().showFieldWhen 'login'

	showEmail: ->
		Template.instance().showFieldWhen [
			'register',
			'forgot-password',
			'email-verification',
			'request-invite'
		]

	showRegisterLink: ->
		Template.instance().showFieldWhen 'login'

	showForgotPasswordLink: ->
		Template.instance().showFieldWhen 'login'

	showBackToLoginLink: ->
		Template.instance().showFieldWhen [
			'register',
			'forgot-password',
			'email-verification',
			'wait-activation',
			'request-invite'
		]

	btnLoginSave: ->
		switch Template.instance().state.get()
			when 'register'
				return t('Submit')
			when 'login'
				if RocketChat.settings.get('LDAP_Enable')
					return t('Login') + ' (LDAP)'
				return t('Login')
			when 'email-verification'
				return t('Send_confirmation_email')
			when 'forgot-password'
				return t('Reset_password')
			when 'request-invite'
				return t('Request Invite')

	waitActivation: ->
		return Template.instance().state.get() is 'wait-activation'

	loginTerms: ->
		return RocketChat.settings.get 'Layout_Login_Terms'

	isLoginRestricted: ->
		if RocketChat.settings.get 'Local_Login_Restricted'
			unless Template.instance().inviteKey or Template.instance().adminKey
				return true
		return false

Template.loginForm.events
	'submit #login-card': (event, instance) ->
		event.preventDefault()

		button = $(event.target).find('button.login')
		RocketChat.Button.loading(button)

		formData = instance.validate()
		if formData
			if instance.state.get() is 'email-verification'
				Meteor.call 'sendConfirmationEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success t('We_have_sent_registration_email')
					instance.state.set 'login'
				return

			if instance.state.get() is 'forgot-password'
				Meteor.call 'sendForgotPasswordEmail', formData.email, (err, result) ->
					RocketChat.Button.reset(button)
					toastr.success t('We_have_sent_password_email')
					instance.state.set 'login'
				return

			if instance.state.get() is 'request-invite'
				Meteor.call 'requestInvitation', formData.email, (error, result) ->
					if error?
						toastr.error error.reason
						return
					RocketChat.Button.reset(button)
					toastr.success t('We will get back to you soon!')
					instance.state.set 'login'
				return

			if instance.state.get() is 'register'
				Meteor.call 'registerUser', formData, (error, result) ->
					RocketChat.Button.reset(button)
					if error?
						if error.error is 'Email already exists.'
							toastr.error t 'Email_already_exists'
						else
							toastr.error error.reason
						return

					Meteor.loginWithPassword formData.email, formData.pass, (error) ->
						if error?.error is 'no-valid-email'
							toastr.success t('We_have_sent_registration_email')
							instance.state.set 'login'
						else if error?.error is 'inactive-user'
							instance.state.set 'wait-activation'

			else
				loginMethod = 'loginWithPassword'
				if RocketChat.settings.get('LDAP_Enable')
					loginMethod = 'loginWithLDAP'

				Meteor[loginMethod] formData.emailOrUsername, formData.pass, (error) ->
					FinLabs.Analytics.track	"Login", login_info: formData.emailOrUsername
					RocketChat.Button.reset(button)
					if error?
						if error.error is 'no-valid-email'
							instance.state.set 'email-verification'
						else
							toastr.error t 'User_not_found_or_incorrect_password'
						return

	'click .register': (e, instance) ->
		if RocketChat.settings.get('Invitation_Required') and not Template.instance().inviteKey
			Template.instance().state.set 'request-invite'
		else
			Template.instance().state.set 'register'

	'click .back-to-login': (e, instance) ->
		Template.instance().state.set 'login'

	'click .forgot-password': (e, instance) ->
		Template.instance().state.set 'forgot-password'

Template.loginForm.onCreated ->
	instance = @
	@inviteKey = FlowRouter.getQueryParam('invite')
	@adminKey = FlowRouter.getQueryParam('admin')
	@state = new ReactiveVar if @inviteKey then 'register' else 'login'

	@validate = ->
		formData = $("#login-card").serializeArray()
		formObj = {}
		validationObj = {}

		for field in formData
			formObj[field.name] = field.value

		if instance.state.get() isnt 'login'
			unless formObj['email'] and /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]+\b/i.test(formObj['email'])
				validationObj['email'] = t('Invalid_email')

		if instance.state.get() isnt 'forgot-password'
			unless formObj['pass']
				validationObj['pass'] = t('Invalid_pass')

		if instance.state.get() is 'register'
			if RocketChat.settings.get 'Accounts_RequireNameForSignUp' and not formObj['name']
				validationObj['name'] = t('Invalid_name')
			if formObj['confirm-pass'] isnt formObj['pass']
				validationObj['confirm-pass'] = t('Invalid_confirm_pass')

		$("#login-card input").removeClass "error"
		unless _.isEmpty validationObj
			button = $('#login-card').find('button.login')
			RocketChat.Button.reset(button)
			$("#login-card h2").addClass "error"
			for key of validationObj
				$("#login-card input[name=#{key}]").addClass "error"
			return false

		$("#login-card h2").removeClass "error"
		$("#login-card input.error").removeClass "error"

		if @inviteKey
			formObj.inviteKey = @inviteKey

		return formObj

	@showFieldWhen = (states) ->
		state = Template.instance().state.get()
		validState = false
		if typeof states is 'string'
			validState = state is states
		else if typeof states is 'object'
			validState = state in states
		return 'hidden' unless validState

Template.loginForm.onRendered ->
	Tracker.autorun =>
		switch this.state.get()
			when 'login', 'forgot-password', 'email-verification'
				Meteor.defer ->
					$('input[name=email]').select().focus()

			when 'register'
				Meteor.defer ->
					$('input[name=name]').select().focus()

	unless RocketChat.settings.get 'Local_Login_Restricted'
		$('.localLogin').removeClass('hidden')

	if @inviteKey
		Meteor.call 'getInvitation', @inviteKey, (error, result) =>
			unless result
				@state.set 'request-invite'
				return
			if result.email
				$('input[name=email]').val(result.email)
			if result.name
				$('input[name=name]').val(result.name)

