Meteor.startup ->

	Accounts.validateLoginAttempt (attempt) ->

		unless attempt.allowed
			return false
		unless RocketChat.settings.get "Require_Payment"
			return attempt.allowed

		userId = attempt.user?.id
		unless FinLabs.payment.purchases.userHasBaseProduct userId
			throw new Meteor.Error 'unsubscribed-user', TAPi18n.__ 'User is not Subscribed'
		return true

	RocketChat.callbacks.add 'afterCreateUser', (options, user) ->
		console.log "OPTIONS"
		console.log options
		console.log "USER"
		console.log user
		return user
	, RocketChat.callbacks.priority.HIGH