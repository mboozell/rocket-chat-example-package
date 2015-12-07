Meteor.methods
	chargeChatSubscription: (token, productId) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] chargeChatSubscription -> Invalid user"

		product = FinLabs.models.Product.findOne productId
		unless product.baseProduct and product.default
			thow new Meteor.Error 'invalid-product', "[methods] chargeChatSubscription -> Invalid user"
		subscription = _.findWhere product.payments, type: 'subscription'
		plan = subscription.plan.id

		user = Meteor.user()
		console.log '[methods] chargeChatSubscription -> '.green,'userId:', Meteor.userId(), "$#{plan}"

		user = Meteor.user()

		FinLabs.payment.util.createSubscription user, plan, token

		RocketChat.authz.removeUsersFromRoles user._id, 'unpaid-user'
		RocketChat.authz.addUsersToRoles user._id, 'user'

		return true
