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
		trialDays = if instance.paymentDetails.get() then instance.paymentDetails.get().trialDays
		if instance.stripeLoaded() and instance.paymentIsLoading.get()
			"Processing"
		else if trialDays
			"Start My #{trialDays} Day Free Trial"
		else
			"Pay Securely"

	paymentPrice: ->
		instance = Template.instance()
		amount = if instance.paymentDetails.get() then instance.paymentDetails.get().amount
		if amount
			amount = (amount / 100).toFixed(2)

	paymentPeriod: ->
		instance = Template.instance()
		interval = if instance.paymentDetails.get() then instance.paymentDetails.get().interval
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
			productId = instance.product.get()._id
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
				Meteor.call 'chargeChatSubscription', token, productId, (error, response) ->
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
	@product = new ReactiveVar null
	@paymentDetails = new ReactiveVar null

	@autorun ->
		subscription = instance.subscribe 'products'
		instance.ready.set subscription.ready()

	@autorun ->
		if instance.ready.get()
			product = FinLabs.models.Product.findOne default: true
			if product
				instance.product.set product
				subscription = _.findWhere product.payments, type: 'subscription'
				instance.paymentDetails.set subscription.plan

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

