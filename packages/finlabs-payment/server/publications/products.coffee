Meteor.publish 'products', ->
	unless this.userId
		return this.ready()

	if RocketChat.authz.hasPermission( @userId, 'view-products') isnt true
		return this.ready()

	console.log '[publish] products'.green

	FinLabs.models.Product.find()
