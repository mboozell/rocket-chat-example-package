FinLabs.updateUserFromInvitation = (user, invitation) ->
	console.log "UPDATING USER FROM INVITATION"
	FinLabs.models.Customer.createWithUserAndCustomerId user._id, invitation.stripe.customer

	subscription = FinLabs.payment.util.getSubscription user._id, invitation.stripe.subscription
	FinLabs.models.Subscription.createFromStripe user._id, subscription

	products = FinLabs.models.Product.findByPlanId(subscription.plan.id).fetch()
	for product in products
		FinLabs.models.Purchase.createInactive user._id, product._id

