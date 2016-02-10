stripe = Npm.require('stripe')

FinLabs.payment.util = new class

	constructor: () ->
		stripeKey = RocketChat.settings.get 'Stripe_Secret_Key'
		@stripe = if stripeKey then new stripe(stripeKey) else {}

	getPlan: (planId) ->
		_retrievePlan = (callback) => @stripe.plans.retrieve planId, callback
		(Meteor.wrapAsync _retrievePlan)()

	getEvent: (eventId) ->
		_retrieveEvent = (callback) => @stripe.events.retrieve eventId, callback
		(Meteor.wrapAsync _retrieveEvent)()

	getSubscriptions: (userId) ->
		customer = @getCustomer(userId)
		unless customer
			return []
		{customerId} = customer
		_retrieveSubscriptions = (callback) => @stripe.customers.listSubscriptions customerId, callback
		(Meteor.wrapAsync _retrieveSubscriptions)().data

	getSubscription: (userId, subscriptionId) ->
		customer = @getCustomer(userId)
		{customerId} = customer
		_retrieveSubscription = (callback) => @stripe.customers.retrieveSubscription customerId, subscriptionId, callback
		(Meteor.wrapAsync _retrieveSubscription)()

	createTransaction: (user, price, action, token, metadata) ->
		customer = @getOrCreateCustomer user, token
		{customerId} = customer
		data =
			amount: price
			currency: "usd"
			customer: customerId
			description: "#{action} for #{user.name} at #{user.emails[0].address} [chat]"
			metadata: metadata
		_chargeCustomer = (callback) => @stripe.charges.create data, callback
		charge = (Meteor.wrapAsync _chargeCustomer)()
		FinLabs.models.Transaction.createFromStripe user._id, charge

	createSubscription: (user, plan, token, metadata) ->
		customer = @getOrCreateCustomer user, token
		{customerId} = customer
		data =
			plan: plan
		_createSubscription = (callback) => @stripe.customers.createSubscription customerId, data, callback
		subscription = (Meteor.wrapAsync _createSubscription)()
		FinLabs.models.Subscription.createFromStripe user._id, subscription

	refundCharge: (charge) ->
		_refundCharge = (callback) => @stripe.refunds.create charge: charge, callback
		(Meteor.wrapAsync _refundCharge)()

	updateOrder: (orderId, update) ->
		_updateOrder = (callback) => @stripe.orders.update orderId, update, callback
		(Meteor.wrapAsync _updateOrder)()

	getCustomer: (userId) ->
		FinLabs.models.Customer.findOneByUser userId

	getOrCreateCustomer: (user, token) ->
		customer = @getCustomer(user._id)
		unless customer
			customer = @createCustomer user, token
		return customer

	createCustomer: (user, token, callback) ->
		data =
			description: "#{user.name} at #{user.emails[0].address} [chat]"
			source: token.id
		_createCustomer = (callback) =>  @stripe.customers.create data, callback
		customer = (Meteor.wrapAsync _createCustomer)()
		_id = FinLabs.models.Customer.createWithUserAndCustomerId user._id, customer.id
		FinLabs.models.Customer.findOneById _id
