Meteor.publish 'productPurchases', (productId) ->
	unless this.userId
		return this.ready()

	if RocketChat.authz.hasPermission( @userId, 'view-purchases') isnt true
		return this.ready()

	console.log '[publish] productPurchases'.green

	FinLabs.models.Purchase.find product: productId
