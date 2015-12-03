Meteor.methods
	addProductChannel: (productId, channelId) ->
		userId = Meteor.userId()

		unless RocketChat.authz.hasPermission userId, 'can-update-product'
			throw new Meteor.Error 'not-authorized', '[methods] addProductChannel -> Not authorized'

		console.log "[methods] addProductChannel ->".green, userId, productId, channelId

