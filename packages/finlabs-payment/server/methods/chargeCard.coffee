Meteor.methods
	chargeRegistrationFee: (token) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] chargeCard -> Invalid user"

		price = RocketChat.settings.get 'Price'
		console.log '[methods] chargeCard -> '.green,'userId:', Meteor.userId(), "$#{price}"

		price = Math.round(parseFloat(price)*100)
		user = Meteor.user()

		payment = new FinLabs.payment.Util()
		payment.createTransaction user, token, price, "Registration Fee"

		RocketChat.authz.removeUsersFromRoles user._id, 'unpaid-user'
		RocketChat.authz.addUsersToRoles user._id, 'user'

		return true
