Meteor.publish 'productChannels', (productId) ->
	unless this.userId
		return this.ready()

	if RocketChat.authz.hasPermission(@userId, 'view-products') isnt true or
		RocketChat.authz.hasPermission(@userId, 'view-other-user-channels') isnt true
			return this.ready()

	console.log '[publish] productChannels'.green

	product = FinLabs.models.Product.findOne productId
	RocketChat.models.Rooms.findAll product.channels
