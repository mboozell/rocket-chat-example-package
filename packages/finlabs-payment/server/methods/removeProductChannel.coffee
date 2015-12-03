Meteor.methods
	removeProductChannel: (productId, channelId) ->
		userId = Meteor.userId()

		unless RocketChat.authz.hasPermission userId, 'can-update-product'
			throw new Meteor.Error 'not-authorized', '[methods] removeProductChannel -> Not authorized'

		console.log "[methods] removeProductChannel ->".green, userId, productId, channelId

