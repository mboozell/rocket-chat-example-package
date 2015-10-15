Template.paymentForm.helpers
	stripeLoaded: ->
		Template.instance().stripeLoaded.get()


Template.paymentForm.onCreated ->
	instance = @
	@stripeLoaded = new ReactiveVar false

	$.ajaxSetup(cache: true)

Template.paymentForm.onRendered ->
	$.getScript('https://js.stripe.com/v2/stripe-debug.js')
		.done =>
			@stripeLoaded.set(true)
			console.log arguments
		.fail ->
			console.log arguments
