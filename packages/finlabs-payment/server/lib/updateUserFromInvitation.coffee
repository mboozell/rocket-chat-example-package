FinLabs.updateUserFromInvitation = (user, invitation) ->
	unless FinLabs.models.Customer.findOneByUser user._id
		FinLabs.models.Customer.createWithUserAndCustomerId user._id, invitation.stripe.customer

	subscription = FinLabs.payment.util.getSubscription user._id, invitation.stripe.subscription
	FinLabs.models.Subscription.createFromStripe user._id, subscription

	products = FinLabs.models.Product.findByPlanId(subscription.plan.id).fetch()
	for product in products
		FinLabs.models.Purchase.createInactive user._id, product._id

	FinLabs.lib.emailAdminsUpdate
		subject: "Chat Update! Invitation Used"
		text: "
			Invitation for #{user.name} <#{invitation.email}>[#{user._id}]
			with key [#{invitation.key}] has been applied.
			Subscription Details {
				plan: #{subscription.plan.id},
				customer: #{invitation.stripe.customer},
				subscription: #{invitation.stripe.subscription}
			}
		"

