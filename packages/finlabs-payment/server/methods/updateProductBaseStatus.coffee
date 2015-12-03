Meteor.methods
	updateProductBaseStatus: (productId, isBaseProduct) ->
		userId = Meteor.userId()

		unless RocketChat.authz.hasPermission userId, 'can-update-product'
			throw new Meteor.Error 'not-authorized', '[methods] updateProductBaseStatus -> Not authorized'

		console.log "[methods] updateProductBaseStatus ->".green, userId, productId, isBaseProduct

		FinLabs.models.Product.updateBaseStatus productId, isBaseProduct
