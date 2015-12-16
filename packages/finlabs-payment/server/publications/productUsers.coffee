Meteor.publish 'productUsers', (productId) ->
	unless this.userId
		return this.ready()

	if RocketChat.authz.hasPermission(@userId, 'view-products') isnt true or
		RocketChat.authz.hasPermission(@userId, 'view-purchases') isnt true
			return this.ready()

	console.log '[publish] productUsers'.green

	userIds = FinLabs.models.Purchase.findAllByProduct(productId).map((purchase) -> purchase._id)
	RocketChat.models.Users.findAll userIds
