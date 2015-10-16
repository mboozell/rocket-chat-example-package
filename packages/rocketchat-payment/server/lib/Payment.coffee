stripe = Npm.require('stripe')

RocketChat.payment = {}

RocketChat.payment.Util = class

	constructor: () ->
		stripeKey = RocketChat.settings.get 'Stripe_Secret_Key'
		@stripe = new stripe(stripeKey)

	createTransaction: (user, token, price, action, metadata) ->
		customer = RocketChat.models.Customer.findOneByUser user._id
		if not customer
			customer = @createCustomer user, token
		{customerId} = customer
		data =
			amount: price
			currency: "usd"
			customer: customerId
			description: "#{action} for #{user.name} at #{user.emails[0].address}"
			metadata: metadata
		_chargeCustomer = (callback) => @stripe.charges.create data, callback
		charge = (Meteor.wrapAsync _chargeCustomer)()
		RocketChat.models.Transaction.createFromStripe user._id, charge

	createCustomer: (user, token, callback) ->
		data =
			description: "#{user.name} at #{user.emails[0].address}"
			source: token.id
		_createCustomer = (callback) =>  @stripe.customers.create data, callback
		customer = (Meteor.wrapAsync _createCustomer)()
		_id = RocketChat.models.Customer.createWithUserAndCustomerId user._id, customer.id
		RocketChat.models.Customer.findOneById _id
