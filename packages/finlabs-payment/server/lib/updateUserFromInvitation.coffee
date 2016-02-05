FinLabs.updateUserFromInvitation = (user, invitation) ->
	if invitation.stripe
		unless FinLabs.models.Customer.findOneByUser user._id
			FinLabs.models.Customer.createWithUserAndCustomerId user._id, invitation.stripe.customer

		subscription = FinLabs.payment.util.getSubscription user._id, invitation.stripe.subscription
		FinLabs.models.Subscription.updateOrAdd subscription

		products = FinLabs.models.Product.findByPlanId(subscription.plan.id).fetch()
		for product in products
			FinLabs.models.Purchase.createInactive user._id, product._id

	if invitation.overrideProducts
		for productId in invitation.overrideProducts
			purchaseId = FinLabs.models.Purchase.findOneWithUserAndProduct(user._id, productId)?._id
			if not purchaseId
				purchaseId = FinLabs.models.Purchase.createActive(user._id, productId).insertedId
			FinLabs.models.Purchase.override purchaseId
			FinLabs.models.Purchase.makeActive purchaseId

	emailText = "Invitation for #{invitation.name} <#{invitation.email}>[#{user._id}]
			with key [#{invitation.key}] has been applied."
	if invitation.stripe
		emailText += "Subscription Details {
				plan: #{subscription.plan.id},
				customer: #{invitation.stripe.customer},
				subscription: #{invitation.stripe.subscription}
			}"

	FinLabs.lib.emailAdminsUpdate
		subject: "Chat Update! Invitation Used"
		text: emailText
