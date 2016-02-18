Meteor.startup ->

	Accounts.validateLoginAttempt (attempt) ->

		unless attempt.allowed
			return false
		unless RocketChat.settings.get "Require_Payment"
			return attempt.allowed

		userId = attempt.user?._id
		unless FinLabs.payment.purchases.userHasBaseProduct userId
			throw new Meteor.Error 'unsubscribed-user', TAPi18n.__ 'User is not Subscribed. Visit WallStJesus.com'
		return true

	toggleRolesForUser = (userId) ->
		unless RocketChat.settings.get "Require_Payment"
			if RocketChat.authz.hasRole userId, 'unpaid-user'
				RocketChat.authz.removeUsersFromRoles userId, 'unpaid-user'
				RocketChat.authz.addUsersToRoles userId, 'user'
			return true

		unless FinLabs.payment.purchases.userHasBaseProduct userId
			if RocketChat.authz.hasRole userId, 'user'
				RocketChat.authz.removeUsersFromRoles userId, 'user'
				RocketChat.authz.addUsersToRoles userId, 'unpaid-user'
		else
			if RocketChat.authz.hasRole userId, 'unpaid-user'
				RocketChat.authz.removeUsersFromRoles userId, 'unpaid-user'
				RocketChat.authz.addUsersToRoles userId, 'user'

	RocketChat.callbacks.add 'afterCreateUser', (options, user) ->
		if options?.invitation
			FinLabs.updateUserFromInvitation user, options.invitation

		if RocketChat.authz.hasRole user._id, 'admin'
			products = FinLabs.models.Product.find().fetch()
			for product in products
				FinLabs.models.Purchase.createActive user._id, product._id

		else if user.services.wordpress
			products = FinLabs.models.Product.findByPaymentType('wordpress').fetch()
			for product in products
				FinLabs.models.Purchase.createInactive user._id, product._id

		else if RocketChat.settings.get "Require_Payment"
			RocketChat.authz.removeUsersFromRoles user._id, 'user'
			RocketChat.authz.addUsersToRoles user._id, 'unpaid-user'

		try
			FinLabs.payment.purchases.checkUser user._id
		toggleRolesForUser(user._id)

		return user
	, RocketChat.callbacks.priority.HIGH

	Accounts.onLogin ->
		userId = Meteor.userId()
		try
			FinLabs.payment.purchases.checkUser userId
		toggleRolesForUser(userId)


	RocketChat.models.Users.find().observe
		changed: (newUser, oldUser) ->
			Meteor.defer ->
				if (newUser.services?.wordpress != oldUser.services?.wordpress or
					newUser.roles?.__global_roles__ != oldUser.roles?.__global_roles__ or
					newUser.username != oldUser.username)
						FinLabs.payment.purchases.checkUser newUser._id
