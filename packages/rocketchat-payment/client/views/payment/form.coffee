Template.paymentForm.helpers
	userName: ->
		Meteor.user().name
	stripeLoaded: ->
		Template.instance().stripeLoaded.get()
	errors: ->
		errors = Template.instance().errors.get()
		return errors
	isLoading: ->
		Template.instance().isLoading.get()
	buttonLabel: ->
		instance = Template.instance()
		t if instance.stripeLoaded() and instance.isLoading.get() then "Processing" else "Pay Securely"

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
			instance.isLoading.set true
			form = {
				name: $('input[name="name"]').val()
				number: $('input[name="number"]').val().replace /\s/g, ''
				cvc: $('input[name="cvc"]').val()
				exp_month: $('input[name="exp-month"]').val()
				exp_year: $('input[name="exp-year"]').val()
			}
			Stripe.card.createToken form, (status, token) ->
				if token.error
					instance.isLoading.set false
					{error} = token
					console.log error
					errors = {}
					errors[error.param] = true
					instance.errors.set(errors)
					return toastr.error error.message
				Meteor.call 'chargeRegistrationFee', token, (error, response) ->
					if error
						instance.isLoading.set false
						toastr.error "Credit Card could not be processed!"

	'keyup input': (e, instance) ->
		instance.errors.set {}

Template.paymentForm.onCreated ->
	instance = @
	@errors = new ReactiveVar {}
	@isLoading = new ReactiveVar true

	$.ajaxSetup(cache: true)

	@stripeLoaded = ->
		!!window.Stripe

Template.paymentForm.onRendered ->
	$.getScript('https://js.stripe.com/v2/')
		.done =>
			@isLoading.set false
			Stripe.setPublishableKey RocketChat.settings.get 'Stripe_Public_Key'
		.fail ->
			toastr.error t "Stripe Couldn't Load"

	if not @data.price
		toastr.error t "No Price Set"
