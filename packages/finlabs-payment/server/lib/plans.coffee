FinLabs.payment.plans = new class
	constructor: ->
		@db = new Meteor.Collection("rocketchat_payment_plans")

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
