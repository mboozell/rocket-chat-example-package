Meteor.methods
	chargeChatSubscription: (token) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] chargeChatSubscription -> Invalid user"

		plan = RocketChat.settings.get 'Subscription_Plan'
		user = Meteor.user()
		console.log '[methods] chargeChatSubscription -> '.green,'userId:', Meteor.userId(), "$#{plan}"

		user = Meteor.user()

		FinLabs.payment.util.createSubscription user, plan, token

		RocketChat.authz.removeUsersFromRoles user._id, 'unpaid-user'
		RocketChat.authz.addUsersToRoles user._id, 'user'

		return true
