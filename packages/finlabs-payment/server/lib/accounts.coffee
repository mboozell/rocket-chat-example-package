Meteor.startup ->

	Accounts.validateLoginAttempt (attempt) ->

		unless attempt.allowed
			return false
		unless RocketChat.settings.get "Require_Payment"
			return attempt.allowed

		userId = attempt.user?._id
		unless FinLabs.payment.purchases.userHasBaseProduct userId
			throw new Meteor.Error 'unsubscribed-user', TAPi18n.__ 'User is not Subscribed'
		return true

	RocketChat.callbacks.add 'afterCreateUser', (options, user) ->
		if RocketChat.authz.hasRole user._id, 'admin'
			products = FinLabs.models.Product.find().fetch()
			for product in products
				FinLabs.models.Purchase.createActive user._id, product._id

		else if user.services.wordpress
			products = FinLabs.models.Product.findByPaymentType('wordpress').fetch()
			for product in products
				FinLabs.models.Purchase.createInactive user._id, product._id

		return user
	, RocketChat.callbacks.priority.HIGH

	Accounts.onLogin ->
		FinLabs.payment.purchases.checkUser Meteor.userId()

	RocketChat.models.Users.find().observe
		changed: (newUser, oldUser) ->
			if (newUser.services.wordpress != oldUser.services.wordpress or
				newUser.roles?.__global_roles__ != oldUser.roles?.__global_roles__ or
				newUser.username != oldUser.username)
					FinLabs.payment.purchases.checkUser newUser._id
