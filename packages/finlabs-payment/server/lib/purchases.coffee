FinLabs.payment.purchases =

	userHas: (userId, productId) ->
		purchases = FinLabs.models.Purchase.findAllWithUserAndProduct(userId, productId).fetch()
		if purchases.length < 1
			return false

		product = FinLabs.models.Product.findOneById productId
		if product.payments.length < 1
			for purchase in purchases
				if purchase.active
					return true
			return false

		for purchase in purchases
			for payment in product.payments
				if _validate.payment[type](userId, purchase, payment)
					unless purchase.active
						FinLabs.models.Purchase.makeActive purchase._id
					return true
			if purchase.active
				FinLabs.models.Purchase.makeInactive purchase._id

		return false

	userHasBaseProduct: (userId) ->
		products = FinLabs.models.Product.findBase().fetch()
		for product in products
			if @userHas userId, product._id
				return true
		return false


	_validate:

		subscription: (userId, purchase, payment) ->
			planId = payment.plan.id

			if FinLabs.models.Subscription.userHasActivePlan userId, planId
				return true

			paymentUtil = new FinLabs.payment.Util()
			try
				for subscription in paymentUtil.getSubscriptions(userId).data
					FinLabs.models.Subscription.updateOrAdd subscription

			FinLabs.models.Subscription.userHasActivePlan userId, planId

		order: (userId, purchase, payment) ->
			return purchase.active

		wordpress: (userId, purchase, payment) ->
			user = Meteor.users.findOne userId
			if user.services.wordpress
				access_token = user.services.wordpress.accessToken
				url = RocketChat.settings.get 'API_Wordpress_URL'
				try
					HTTP.call url, params: access_token: access_token
					return true
			return false
