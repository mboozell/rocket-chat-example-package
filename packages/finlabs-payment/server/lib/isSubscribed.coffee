FinLabs.payment.isSubscribed = (userId, planId) ->
	subscriptions = FinLabs.models.Subscription.findActiveByUserAndPlan userId, planId
	if subscriptions.count() > 0
		return true

	paymentUtil = new FinLabs.payment.Util()

	try
		for subscription in paymentUtil.getSubscriptions().data
			FinLabs.models.Subscription.updateOrAdd subscription

	subscriptions = FinLabs.models.Subscription.findActiveByUserAndPlan userId, planId
	if subscriptions.count() > 0
		return true

	user = Meteor.users.findOne userId
	if user.services.wordpress
		access_token = user.services.wordpress.accessToken
		url = RocketChat.settings.get 'API_Wordpress_URL'
		try
			HTTP.call url, params: access_token: access_token
			return true

	return false

