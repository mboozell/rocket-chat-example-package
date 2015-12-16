Meteor.methods
	removeProductUser: (productId, userId) ->

		unless RocketChat.authz.hasPermission Meteor.userId(), 'can-update-product'
			throw new Meteor.Error 'not-authorized', '[methods] removeProductUser -> Not authorized'

		FinLabs.models.Purchase.unOverride userId, productId
