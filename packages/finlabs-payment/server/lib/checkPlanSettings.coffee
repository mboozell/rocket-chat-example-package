FinLabs.payment.checkPlanSettings = (name) ->
	planId = RocketChat.settings.get 'Subscription_Plan'
	key = RocketChat.settings.get 'Stripe_Secret_Key'
	if planId and key
		paymentUtil = new FinLabs.payment.Util()
		try
			plan = paymentUtil.getPlan planId
			RocketChat.models.Settings.updateValueById 'Subscription_Price', (plan.amount / 100.0)
			RocketChat.models.Settings.updateValueById 'Subscription_Interval', plan.interval
			RocketChat.models.Settings.updateValueById 'Subscription_Trial_Days', plan.trial_period_days
		catch
			RocketChat.models.Settings.updateValueById 'Subscription_Price', -1
