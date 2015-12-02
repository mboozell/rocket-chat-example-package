FinLabs.payment.products = new class

	add: (name, tools, channelNames, payments, options) ->
		channels = []
		for channelName in channelNames
			channel = RocketChat.models.Rooms.findOneByName channelName
			if channel
				channels.push channel._id
			else
				channel = RocketChat.models.Rooms.createWithTypeAndName 'p', channelName
				channels.push channel._id
		roles = []
		for tool in tools
			toolRoles = FinLabs.payment.tools.getRoles tool
			if toolRoles
				roles = _.union roles, toolRoles

		FinLabs.models.Product.addOrUpdate name, roles, channels, payments, options

Meteor.startup ->

	updatePurchases = (product) ->
		admins = RocketChat.authz.getUsersInRole 'admin'
		for admin in admins
			FinLabs.models.Purchase.createActive user._id, product._id

		isWordpressProduct = _.findWhere(product.payments, {type: 'wordpress'})
		if isWordpressProduct
			wordpressUsers = RocketChat.models.Users.findUsersHavingService 'wordpress'
			for user in wordpressUsers
				FinLabs.models.Purchase.createInactive user._id, product._id

		purchases = FinLabs.models.Purchase.findAllByProduct product._id
		for purchase in purchases
			FinLabs.payment.purchases.checkPurchase purchase

	FinLabs.models.Product.find().observe
		changed: updatePurchases
		added: updatePurchases
