FinLabs.payment.products = new class

	add: (name, roles, channelNames, payments, options) ->
		channels = []
		for channelName in channelNames
			channel = RocketChat.models.Rooms.findOneByName channelName
			if channel
				channels.push channel._id
			else
				channel = RocketChat.models.Rooms.createWithTypeAndName 'p', channelName
				channels.push channel._id
		FinLabs.models.Product.addOrUpdate name, roles, channels, payments, options

Meteor.startup ->

	FinLabs.models.Product.find().observe
		changed: (product) ->
			purchases = FinLabs.models.Purchase.findAllByProduct product._id
			for purchase in purchases
				FinLabs.payment.purchases.checkPurchase purchase
