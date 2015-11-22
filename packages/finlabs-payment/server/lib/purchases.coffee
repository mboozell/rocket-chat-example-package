FinLabs.payment.purchases =

	userHas: (userId, productId) ->
		self = FinLabs.payment.purchases
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
				if self._validate[payment.type](userId, purchase, payment)
					unless purchase.active
						FinLabs.models.Purchase.makeActive purchase._id
					return true
			if purchase.active
				FinLabs.models.Purchase.makeInactive purchase._id

		return false

	userHasBaseProduct: (userId) ->
		self = FinLabs.payment.purchases
		if RocketChat.authz.hasRole userId, 'admin'
			return true

		products = FinLabs.models.Product.findBase().fetch()
		for product in products
			if self.userHas userId, product._id
				return true
		return false

	checkPurchase: (purchase) ->
		self = FinLabs.payment.purchases
		if purchase.active
			self.enablePurchase purchase
		unless self.userHas purchase.user, purchase.product
			self.disablePurchase purchase

	enablePurchase: (purchase) ->
		user = Meteor.users.findOne purchase.user
		product = FinLabs.models.Product.findOneById purchase.product
		RocketChat.authz.addUsersToRoles purchase.user, product.roles
		for roomId in product.channels
			room = RocketChat.models.Rooms.findOneById roomId
			RocketChat.callbacks.run 'beforeJoinRoom', user, room
			RocketChat.models.Rooms.addUsernameById roomId, user.username
			if not RocketChat.models.Subscriptions.findOneByRoomIdAndUserId roomId, user._id
				RocketChat.models.Subscriptions.createWithRoomAndUser room, user,
					ts: new Date()
					open: true
					alert: true
					unread: 1
				RocketChat.models.Messages.createUserJoinWithRoomIdAndUser roomId, user
			Meteor.defer ->
				RocketChat.callbacks.run 'afterJoinRoom', user, room

	disablePurchase: (purchase) ->
		user = Meteor.users.findOne purchase.user
		product = FinLabs.models.Product.findOneById purchase.product
		RocketChat.authz.removeUsersFromRoles purchase.user, product.roles
		for roomId in product.channels
			room = RocketChat.models.Rooms.findOneById roomId
			RocketChat.models.Rooms.removeUsernameById roomId, user.username
			RocketChat.models.Subscriptions.removeByRoomIdAndUserId roomId, user._id
			Meteor.defer ->
				RocketChat.callbacks.run 'afterLeaveRoom', user, room

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
				url += if url[url.length-1] != '/' then '/' else ''
				url += "wp-json/finlabs/v1/user/subscribed"
				try
					HTTP.get url, params: access_token: access_token
					return true
			return false


Meteor.startup ->

	FinLabs.models.Purchase.find().observe

		added: FinLabs.payment.purchases.checkPurchase
		changed: FinLabs.payment.purchases.checkPurchase
		removed: FinLabs.payment.purchases.checkPurchase




