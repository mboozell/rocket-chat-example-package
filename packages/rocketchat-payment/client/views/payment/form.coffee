Template.paymentForm.helpers
	stripeLoaded: ->
		Template.instance().stripeLoaded.get()

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
		$('#payment-form-submit').prop 'disabled', true
		if Stripe
			form = $('#payment-form')
			Stripe.card.createToken form, (status, response) ->
				if response.error
					$('#payment-form-submit').prop 'disabled', false
					console.log response.error
				else
					console.log response

Template.paymentForm.onCreated ->
	instance = @

	$.ajaxSetup(cache: true)


Template.paymentForm.onRendered ->
	$.getScript('https://js.stripe.com/v2/')
		.done ->
			$('#payment-form-submit').prop 'disabled', false
			Stripe.setPublishableKey RocketChat.settings.get 'Stripe_Public_Key'
		.fail ->
			toastr.error t "Stripe Couldn't Load"

	if not @data.price
		toastr.error t "No Price Set"
