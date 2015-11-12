Meteor.methods
	chargeChatSubscription: (token) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] chargeChatSubscription -> Invalid user"

		price = RocketChat.settings.get 'Subscription_Plan'
		console.log '[methods] chargeChatSubscription -> '.green,'userId:', Meteor.userId(), "$#{price}"

		price = Math.round(parseFloat(price)*100)
		user = Meteor.user()

		paymentUtil = new FinLabs.payment.Util()
		paymentUtil.createTransaction user, plan, token

		RocketChat.authz.removeUsersFromRoles user._id, 'unpaid-user'
		RocketChat.authz.addUsersToRoles user._id, 'user'

		return true
