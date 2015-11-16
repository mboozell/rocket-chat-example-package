RocketChat.settings.addGroup 'Payment'
RocketChat.settings.add 'Require_Payment', false, { type: 'boolean', group: 'Payment', public: true }
RocketChat.settings.add 'Subscription_Plan', '', { type: 'string', group: 'Payment', public: true }
RocketChat.settings.add 'Stripe_Public_Key', '', { type: 'string', group: 'Payment', public: true}
RocketChat.settings.add 'Stripe_Secret_Key', '', { type: 'string', group: 'Payment' }
RocketChat.settings.add 'Subscription_Price', -1, { type: 'float', public: true }
RocketChat.settings.add 'Subscription_Interval', '', { type: 'string', public: true }
RocketChat.settings.add 'Subscription_Trial_Days', 0, { type: 'float', public: true }

Meteor.startup ->
	checkSubscriptionPrice = (record) ->
		name = record._id
		if Match.test name, 'Subscription_Plan'
			FinLabs.payment.checkPlanSettings()

	RocketChat.models.Settings.find().observe
		added: checkSubscriptionPrice
		changed: checkSubscriptionPrice
		removed: checkSubscriptionPrice

Meteor.startup ->
	Accounts.onLogin () ->
		userId = Meteor.user()._id
		planId = RocketChat.settings.get "Subscription_Plan"
		subscribed = FinLabs.payment.isSubscribed(userId, planId)

		if not subscribed
			RocketChat.authz.removeUsersFromRoles userId, 'user'
			RocketChat.authz.addUsersToRoles userId, 'unpaid-user'
