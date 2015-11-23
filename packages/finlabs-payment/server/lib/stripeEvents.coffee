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

		plan: (plan) ->
			FinLabs.models.Product.updatePlan(plan)
