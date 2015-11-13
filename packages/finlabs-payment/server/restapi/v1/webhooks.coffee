Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true

eventLog = new class
	constructor: ->
		@db = new Meteor.Collection("rocketchat_payment_events")

	exists: (eventId) ->
		@db.findOne eventId: eventId

	add: (event) ->
		event.eventId = event.id
		delete event.id
		delete event.data
		event.completed = false
		@db.insert event

	complete: (event) ->
		@db.update {eventId: event.id}, {$set: {completed: true}}

eventHandlers =
	subscription: (subscription) ->
		FinLabs.models.Subscription.updateOrAdd(subscription)


Api.addRoute 'payment/webhook/stripe', authRequired: false,
	post: ->
		console.log "WEBHOOK STARTED"
		eventId = @bodyParams.id
		if eventId
			if eventLog.exists eventId
				return status: "success"
			eventLog.add @bodyParams
			paymentUtil = new FinLabs.payment.Util()
			# event = @bodyParams
			event = paymentUtil.getEvent(eventId)
			object = event.data.object
			console.log event
			if eventHandlers[object.object]
				eventHandlers[object.object](object)
		eventLog.complete event
		return status: "success"
