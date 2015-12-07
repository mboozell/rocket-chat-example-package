Template.paymentForm.helpers

	userName: ->
		Meteor.user().name

	stripeLoaded: ->
		Template.instance().stripeLoaded()

	paymentErrors: ->
		errors = Template.instance().paymentErrors.get()
		return errors

	paymentIsLoading: ->
		Template.instance().paymentIsLoading.get()

	buttonLabel: ->
		instance = Template.instance()
		trialDays = instance.paymentDetails.trialDays
		if instance.stripeLoaded() and instance.paymentIsLoading.get()
			"Processing"
		else if trialDays
			"Start My #{trialDays} Day Free Trial"
		else
			"Pay Securely"

	paymentPrice: ->
		Template.instance().paymentDetails.amount

	paymentPeriod: ->
		interval = Template.instance().paymentDetails.trialDays
		return if interval then "/#{interval}" else ""

Template.paymentForm.events

	'keyup input[name="number"]': (e, instance) ->
		field = $('input[name="number"]')
		if e.keyCode > 47 and e.keyCode < 58
			value = field.val()
			value = value.replace /\s/g, ''
			value = value.replace /.{4}/g, (match) -> "#{match} "
			value = value.trim()
			field.val(value)

	'submit #payment-form': (e, instance) ->
		e.preventDefault()
		if instance.stripeLoaded()
			instance.paymentIsLoading = true
			form =
				name: $('input[name="name"]').val()
				number: $('input[name="number"]').val().replace /\s/g, ''
				cvc: $('input[name="cvc"]').val()
				exp_month: $('input[name="exp-month"]').val()
				exp_year: $('input[name="exp-year"]').val()
			Stripe.card.createToken form, (status, token) ->
				if token.error
					instance.paymentIsLoading = false
					{error} = token
					console.log error
					errors = {}
					errors[error.param] = true
					instance.paymentErrors.set(errors)
					return toastr.error error.message
				Meteor.call 'chargeChatSubscription', token, (error, response) ->
					if error
						instance.paymentIsLoading = false
						toastr.error "Credit Card could not be processed!"

	'keyup input': (e, instance) ->
		instance.paymentErrors.set {}

Template.paymentForm.onCreated ->
	instance = @
	@paymentErrors = new ReactiveVar {}
	@paymentIsLoading = new ReactiveVar true
	@ready = new ReactiveVar false

	@autorun ->
		subscription = instance.subscribe 'products'
		instance.ready.set subscription.ready()

	@autorun ->
		if instance.ready.get()
			product = FinLabs.models.Product.findOne default: true
			console.log product
			if product
				instance.product = product
				for payment in product.payments
					if payment.type is 'subscription'
						instance.paymentDetails = payment.plan
						break

	$.ajaxSetup(cache: true)

	@stripeLoaded = ->
		!!window.Stripe

Template.paymentForm.onRendered ->
	$.getScript('https://js.stripe.com/v2/')
		.done =>
			@paymentIsLoading.set false
			Stripe.setPublishableKey RocketChat.settings.get 'Stripe_Public_Key'
		.fail ->
			toastr.error t "Stripe Couldn't Load"

