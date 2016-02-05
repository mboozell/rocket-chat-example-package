FinLabs.payment.stripeEvents =

	logs: new class

		constructor: ->
			@db = new Meteor.Collection("rocketchat_payment_events")

		exists: (eventId) ->
			@db.findOne eventId: eventId, completed: false

		add: (event) ->
			event.eventId = event.id
			delete event.id
			delete event.data
			event.completed = false
			@db.insert event

		complete: (event) ->
			@db.update {eventId: event.id}, {$set: {completed: true}}

	handlers:

		subscription: (subscription) ->
			FinLabs.models.Subscription.updateOrAdd(subscription)

			customer = FinLabs.models.Customer.findOneByCustomerId subscription.customer
			if customer
				user = RocketChat.models.Users.findOneById customer.user
				email = user.emails[0].address
			else
				email = "<email not found>"

			unless subscription.status is 'active'
				FinLabs.lib.emailAdminsUpdate
					subject: "Subscription Payment Ended!"
					text: "Subscription [#{subscription.plan.id}] payment for #{email} [#{subscription.customer}] has changed to #{subscription.status}."

		plan: (plan) ->
			FinLabs.models.Product.updatePlan(plan)

		order: (order) ->
			_id = FinLabs.models.Order.updateOrAdd order
			order = FinLabs.models.Order.findOneById _id
			FinLabs.payment.orders.handleNew order
