Api = new Restivus
	version: 'v1'
	useDefaultAuth: true
	prettyJson: true

Api.addRoute 'payment/webhook/stripe', authRequired: false,
	post: ->
		console.log "WEBHOOK STARTED"
		eventId = @bodyParams.id
		if eventId
			if FinLabs.payment.stripeEvents.log.exists eventId
				return status: "success"
			FinLabs.payment.stripeEvents.log.add @bodyParams
			paymentUtil = new FinLabs.payment.Util()
			# event = @bodyParams
			event = paymentUtil.getEvent(eventId)
			object = event.data.object
			eventHandler = FinLabs.payment.stripeEvents.handlers[object.object]
			if eventHandler
				eventHandler(object, event)
		FinLabs.payment.stripeEvents.log.complete event
		return status: "success"
