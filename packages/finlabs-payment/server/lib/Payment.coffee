stripe = Npm.require('stripe')

FinLabs.payment = {}

FinLabs.payment.Util = class

	constructor: () ->
		stripeKey = RocketChat.settings.get 'Stripe_Secret_Key'
		@stripe = new stripe(stripeKey)

	getPlan: (planId) ->
		_retrievePlan = (callback) => @stripe.plans.retrieve planId, callback
		(Meteor.wrapAsync _retrievePlan)()

	getEvent: (eventId) ->
		_retrieveEvent = (callback) => @stripe.events.retrieve eventId, callback
		(Meteor.wrapAsync _retrieveEvent)()

	createTransaction: (user, price, action, token, metadata) ->
		customer = @getCustomer user, token
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
		customer = @getCustomer user, token
		{customerId} = customer
		data =
			plan: plan
		_createSubscription = (callback) => @stripe.customers.createSubscription customerId, data, callback
		subscription = (Meteor.wrapAsync _createSubscription)()
		FinLabs.models.Subscription.createFromStripe user._id, subscription

	getCustomer: (user, token) ->
		customer = FinLabs.models.Customer.findOneByUser user._id
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
