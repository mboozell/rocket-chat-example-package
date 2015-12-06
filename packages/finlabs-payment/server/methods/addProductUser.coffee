Meteor.methods
	addProductUser: (productId, userId) ->

		unless RocketChat.authz.hasPermission Meteor.userId(), 'can-update-product'
			throw new Meteor.Error 'not-authorized', '[methods] addProductUser -> Not authorized'

		FinLabs.models.Purchase.createActive userId, productId, override: true
