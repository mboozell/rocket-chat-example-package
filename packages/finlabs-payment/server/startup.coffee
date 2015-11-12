RocketChat.settings.addGroup 'Payment'
RocketChat.settings.add 'Require_Payment', false, { type: 'boolean', group: 'Payment', public: true }
RocketChat.settings.add 'Subscription_Plan', '', { type: 'string', group: 'Payment', public: true }
RocketChat.settings.add 'Stripe_Public_Key', '', { type: 'string', group: 'Payment', public: true}
RocketChat.settings.add 'Stripe_Secret_Key', '', { type: 'string', group: 'Payment' }
RocketChat.settings.add 'Subscription_Price', '', { type: 'float', public: true }

Meteor.startup ->
	checkSubscriptionPrice = (record) ->
		name = record._id
		if Match.test name, 'Subscription_Plan'
			planId = RocketChat.settings.get 'Subscription_Plan'
			key = RocketChat.settings.get 'Stripe_Secret_Key'
			if planId and key
				paymentUtil = new FinLabs.payment.Util()
				try
					plan = paymentUtil.getPlan planId
					RocketChat.models.Settings.updateValueById 'Subscription_Price', (plan.amount / 100.0)
				catch
					RocketChat.models.Settings.updateValueById 'Subscription_Price', -1

	RocketChat.models.Settings.find().observe
		added: checkSubscriptionPrice
		changed: checkSubscriptionPrice
		removed: checkSubscriptionPrice

